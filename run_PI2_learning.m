function runPI2Learning(protocol_name)
% This is a simple implementation of Pi2 learning on a 2 DOF Discrete
% Movement Primitive, i.e., an entirely planar implementation. It serves as
% illustration how PI2 learning works. To allow easy changes, cost
% functions and DMP start state and goal state have been kept modular. The
% experimental protocal is read from a protocal text file, <protocol_name>,
% which should be self-explantory.
%
% This work is based on the paper:
% Theodorou E, Buchli J, Schaal S (2010) Reinforcement learning in high dimensional
% state spaces: A path integral approach. Journal of Machine Learning Research
%
% The simulation control a 2 DOF pendulum with the DMPs. This could be easily
% changed to be a more complex nonlinear system.
%
% Stefan Schaal, June 2010
%
% EDIT: Ronald Olsthoorn, April 2016
%
% initializes a 2 DOF DMP -- this is dones as two independent DMPs as the
% Matlab DMPs currently do not support multi-DOF DMPs.

global n_dmps;      % number of DMPs used
n_dmps = 2;

global par;         % robot configuration
par = readPar;

% read the protocol file
protocol = readProtocol(protocol_name);

% run all protocol items
for i=1:length(protocol),
    runProtocol(protocol(i));
end

%--------------------------------------------------------------------------n
function runProtocol(p)
% runs a particular protocol item, i.e., one line from the protocol specs

global n_dmps;
global n_rfs;
global dcps;
global Ts;
global wrapflag;
global control_method;

n_rfs = p.n_rfs;
control_method = str2func(p.controller);
wrapflag =0;

% the integration time step is set fixed to 10 milli seconds
Ts = 0.01;

% create the big data matrix for the roll-out data: We simply store all roll-out data in
% this matrix and evalute it late efficiently in vectorized from for learning updates
D = p;
D.t             = 0:Ts:(p.duration-Ts);   % time vector
D.n_end         = length(D.t);                % length of total simulation
D.rollouts.dmp(1:n_dmps) = struct(...
    'xd',zeros(D.n_end,3),...             % DMP desired state
    'bases',zeros(D.n_end,n_rfs),...      % DMP bases function vector
    'eps',zeros(D.n_end,n_rfs),...        % DMP noisy parameters
    'theta_eps',zeros(D.n_end,n_rfs),...  % DMP noisy parameters+kernel weights
    'psi',zeros(D.n_end,n_rfs));          % DMP Gaussian kernels

D.rollouts.q        = zeros(D.n_end,2*n_dmps);          % point mass pos
D.rollouts.u        = zeros(D.n_end,2*n_dmps);          % point mass command

if strcmp('none', p.ref)
    D.ref = 'none';         % no reference function used in reward function
else
    eval(sprintf('D.ref=%s(D);',p.ref));
    D.ref_ss = ref_trajectory_ss(D);

    D.ref_ss_d = [0 diff(D.ref_ss(1,:))/Ts
              0 diff(D.ref_ss(2,:))/Ts  ];
    D.ref_ss_dd= [0 diff(D.ref_ss_d(1,:))/Ts
              0 diff(D.ref_ss_d(2,:))/Ts];
end

D_eval         = D;     % used for noiseless cost assessment
D_eval.reps    = 1;     % only one repetition for evaluation
D_eval.std     = 0;     
D_eval.n_reuse = 0;

D.rollouts(1:D.reps) = D.rollouts;  % one data structure for each repetition

for i=1:n_dmps,                     % initialize DMPs
    dcp('clear',i);
    dcp('init',i,n_rfs,sprintf('pi2_dmp_%d',i),0);
    
    % use the in-built function to initialize the dcp with reference tarjectory
    dcp('Batch_Fit',i,D.duration,Ts,D.ref_ss(i,:)',D.ref_ss_d(i,:)',D.ref_ss_dd(i,:)');  
    dcp('reset_state',i,D.start(i));
    dcp('set_goal',i,D.goal(i),1);
end

D.psi = dcp('run_psi',1, D.duration, Ts); % Obtain basis functions
D_eval.psi = D.psi;
dcp('reset_state',1,D.start(1));
dcp('set_goal',1,D.goal(1),1);

R_total = zeros(p.updates,2); % used to store the learning trace
Weights = zeros(p.updates, n_rfs); % used to store weight trace

for i=1:D.updates,
         
    % perform one noiseless evaluation to get the cost
    D_eval=run_rollouts(D_eval,1);
      
    % compute all costs in batch from, as this is faster in matlab
    eval(sprintf('R_eval=%s(D_eval);',D_eval.cost));      
    
    % store the noise-less reward and the weights
    R_total(i,:) = [i*(D.reps-D.n_reuse)+D.n_reuse,sum(R_eval)];  
    Weights(i,:) = dcps(1).w';
    
    % run learning roll-outs with a noise annealing multiplier
    noise_mult = double(D.updates - i+1)/double(D.updates);
    noise_mult = max([0.5 noise_mult]);
    
    D=run_rollouts(D,noise_mult);

    % compute all costs in batch from, as this is faster vectorized math in matlab
    eval(sprintf('R=%s(D);',D.cost));
    
    % visualization: plot at the start and end of the updating
    if mod(i,10)== 1,
        fprintf('%5d.Cost = %f \n',i,sum(R_eval));
        printProgress(D, D_eval, R, R_eval, i);
    end
    
    % perform the PI2 update
    updatePI2(D,R);

    % reuse of roll-out: the n_reuse best trials and re-evalute them the next update in
    % the spirit of importance sampling
    if (i > 1 && D.n_reuse > 0)
        [~,inds]=sort(sum(R,1));
        for j=1:D.n_reuse,
            Dtemp = D.rollouts(j);
            D.rollouts(j) = D.rollouts(inds(j));
            D.rollouts(inds(j)) = Dtemp;
        end
    end
    
end

% perform the final noiseless evaluation to get the final cost
D_eval=run_rollouts(D_eval,1);

% compute all costs in batch from, as this is faster in matlab
eval(sprintf('R_eval=%s(D_eval);',D_eval.cost));
fprintf('%5d.Cost = %f \n',i,sum(R_eval));

printResult(D, D_eval, R, R_eval, R_total);

%-------------------------------------------------------------------------------
function updatePI2(D,R)
% D is the data structure of all roll outs, and R the cost matrix for these roll outs
global n_dmps;
global n_rfs;
global dcps;

n_reps = D.reps;        % number of roll-outs
n_end = D.n_end;        % final time step 

% compute the accumulate cost
S = rot90(rot90(cumsum(rot90(rot90(R)))));

% compute the exponentiated cost with the special trick to automatically
% adjust the lambda scaling parameter
maxS = max(S,[],2);
minS = min(S,[],2);

h = 10; % this is the scaling parameters in side of the exp() function (see README.pdf)
expS = exp(-h*(S - minS*ones(1,n_reps))./((maxS-minS+1e-20)*ones(1,n_reps)));

% the probabilty of a trajectory
P = expS./(sum(expS,2)*ones(1,n_reps));

% compute the projected noise term. It is computationally more efficient to break this
% operation into inner product terms.
PMeps = zeros(n_dmps,n_reps,n_end,n_rfs);

for j=1:n_dmps,
    for k=1:n_reps,
        
        % compute g'*eps in vector form
        gTeps = sum(D.rollouts(k).dmp(j).bases.*(D.rollouts(k).dmp(j).theta_eps-ones(n_end,1)*dcps(j).w'),2);
        %gTeps = sum(D.rollouts(k).dmp(j).bases.*(D.rollouts(k).dmp(j).eps),2);

        % compute g'g
        gTg  = sum(D.rollouts(k).dmp(j).bases.*D.rollouts(k).dmp(j).bases,2);
        
        % compute P*M*eps = P*g*g'*eps/(g'g) from previous results
        PMeps(j,k,:,:) = D.rollouts(k).dmp(j).bases.*((P(:,k).*gTeps./(gTg + 1.e-10))*ones(1,n_rfs));
    end
end

% compute the parameter update per time step
dtheta = reshape(sum(PMeps,2),n_dmps,n_end,n_rfs);

% average updates over time
% the time weighting matrix (note that this done based on the true duration of the
% movement, while the movement "recording" is done beyond D.duration). Empirically, this
% weighting accelerates learning
N = [(D.n_end:-1:1)'
    ones(n_end-D.n_end,1)
    ];

% the final weighting vector takes the kernel activation into account
W = (N*ones(1,n_rfs)).*D.psi;

% ... and normalize through time
W = W./(ones(n_end,1)*sum(W,1));

% compute the final parameter update for each DMP
dtheta = reshape(sum(dtheta.*repmat(reshape(W,[1,n_end,n_rfs]),[n_dmps 1 1]),2),n_dmps,n_rfs);

% and update the parameters by directly accessing the dcps data structure
for i=1:n_dmps,
    dcps(i).w = dcps(i).w + dtheta(i,:)';
end

%-------------------------------------------------------------------------------
function D=run_rollouts(D,noise_mult)
% a dedicated function to run muultiple roll-outs using the specifictions in D. 
% noise_mult allows decreasing the noise with the number of roll-outs, which gives
% smoother converged performance (but it is not needed for convergence).

global n_dmps;
global control_method;
global Ts;
global par;

start = D.n_reuse + 1;  % take into account the reused roll-outs.
if (noise_mult == 1)    % indicates very first batch of rollouts.
    start = 1;       
end

D = gen_epsilon(D, start, noise_mult);

for k=start:D.reps, % Run DMPs
    
    % reset the DMP
    for j=1:n_dmps,
        dcp('reset_state',j,D.start(j));
        dcp('set_goal',j,D.goal(j),1);
        % dcp('set_scale',j,abs(D.goal(j)-D.start(j)));
    end
    
    % run the DMPs to create the desired trajectory
    for n=1:D.n_end,                    
        for j=1:n_dmps,                           
            [y,yd,ydd,b]=dcp('run',j,D.duration,Ts,0,0,1,1,D.rollouts(k).dmp(j).eps(n,:)');  
            D.rollouts(k).dmp(j).xd(n,:)   = [y,yd,ydd];% desired state.
            D.rollouts(k).dmp(j).bases(n,:) = b';       % bases. used for updates.
        end      
    end
    
end

for k=start:D.reps, % Run the robotic arm    
    q = [D.start(1);0;D.start(2);0];  
    
    for n=1:D.n_end,
        
        % integrate simulated 2 DoF robot arm with inverse dynamics control
        % based on DMP output -- essentially, this just perfectly realizes
        % the DMP output, but one could add noise to this equation to make
        % it more interesting.
        
        r = [D.rollouts(k).dmp(1).xd(n,:)';D.rollouts(k).dmp(2).xd(n,:)'];
        
        [q_next] = f_closed_loop(q,r, control_method, par);        
        q = q_next';
        
        D.rollouts(k).q(n,:)   = q';    % store the state

    end
end