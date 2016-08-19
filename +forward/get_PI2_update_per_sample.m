function [ dtheta ] = get_PI2_update_per_sample( S, forward_par )

% returns the new policy, based on the new set of roll-outs.
% S is the data structure of all roll outs.

global n_dmps;
n_dmp_bf = forward_par.n_dmp_bf;
global dcps;

n_reps = forward_par.reps;       % number of roll-outs
n_end = S.n_end;            % final time step

P = forward.get_probability_trajectories(S, forward_par);

% compute the projected noise term. It is computationally more efficient to break this
% operation into inner product terms.
PMeps = zeros(n_dmps, n_reps, n_end, n_dmp_bf);

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

% compute the final parameter update for each DMP
dtheta = reshape(sum(PMeps.*repmat(reshape(S.time_weight, [1, 1, n_end, n_dmp_bf]), ... 
                    [n_dmps n_reps 1 1]), ... 
                    3), ...
                    [n_dmps n_reps n_dmp_bf]);

end

