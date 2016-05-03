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