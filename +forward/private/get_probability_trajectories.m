function [ P ] = get_probability_trajectories( S, forward_par )

n_reps = forward_par.reps;       % number of roll-outs
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

end

