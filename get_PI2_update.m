function theta = get_PI2_update(S, ro_par)
% returns the new policy, based on the new set of roll-outs.
% S is the data structure of all roll outs.

global n_dmps;
n_dmp_bf = ro_par.n_dmp_bf;
global dcps;

n_reps = ro_par.reps;       % number of roll-outs
n_end = S.n_end;            % final time step

R_cum = zeros(n_end, n_reps);

for k=1:n_reps
    R_cum(:,k) = -S.rollouts(k).r;
end

% compute the exponentiated cost with the special trick to automatically
% adjust the lambda scaling parameter
maxS = max(R_cum,[],2);
minS = min(R_cum,[],2);

h = 10; % this is the scaling parameters in side of the exp() function (see README.pdf)
expS = exp(-h*(R_cum - minS*ones(1,n_reps))./...
    ((maxS-minS+1e-20)*ones(1,n_reps)));

% the probabilty of a trajectory
P = expS./(sum(expS,2)*ones(1,n_reps));

% compute the projected noise term. It is computationally more efficient to break this
% operation into inner product terms.
PMeps = zeros(n_dmps,n_reps,n_end,n_dmp_bf);

for j=1:n_dmps,
    for k=1:n_reps,
        
        % compute g'*eps in vector form
        gTeps = sum(S.rollouts(k).dmp(j).bases.*(S.rollouts(k).dmp(j).theta_eps-ones(n_end,1)*dcps(j).w'),2);
        %gTeps = sum(D.rollouts(k).dmp(j).bases.*(D.rollouts(k).dmp(j).eps),2);
        
        % compute g'g
        gTg  = sum(S.rollouts(k).dmp(j).bases.*S.rollouts(k).dmp(j).bases,2);
        
        % compute P*M*eps = P*g*g'*eps/(g'g) from previous results
        PMeps(j,k,:,:) = S.rollouts(k).dmp(j).bases.*((P(:,k).*gTeps./(gTg + 1.e-10))*ones(1,n_dmp_bf));
    end
end

% average updates over time
% the time weighting matrix (note that this done based on the true duration of the
% movement, while the movement "recording" is done beyond D.duration). Empirically, this
% weighting accelerates learning
N = [(S.n_end:-1:1)'
    ones(n_end-S.n_end,1)
    ];

% the final weighting vector takes the kernel activation into account
W = (N*ones(1, n_dmp_bf)).*S.psi;

% ... and normalize through time
W = W./(ones(n_end, 1)*sum(W, 1));

% compute the final parameter update for each DMP
dtheta = reshape(sum(PMeps.*repmat(reshape(W, [1, 1, n_end, n_dmp_bf]),[n_dmps n_reps 1 1]),3), [n_dmps n_reps n_dmp_bf]);

% normalize over samples
dtheta = dtheta./repmat(sum(dtheta,2), [1, n_reps, 1]);

% add 
theta = zeros(n_dmps*n_dmp_bf, n_reps);

for i=1:n_dmps,
    
    theta((((i-1)*n_dmp_bf)+1):(i*n_dmp_bf),:) = dcps(i).w*ones(1,n_reps) + squeeze(dtheta(i,:,:))';

end