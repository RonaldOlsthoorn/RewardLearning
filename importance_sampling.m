function [ S ] = importance_sampling( S, ro_par, n_reuse )
% reuse of roll-out: the n_reuse best trials and re-evalute them the
% next update in the spirit of importance sampling

R = zeros(ro_par.reps, 1);

for k=1:ro_par.reps
    R(k) = S.rollouts(k).R(1,1);
end    

[~,inds]=sort(R);

for j=1:(length(R)-n_reuse),
    
    Stemp =    S.rollouts(inds(j));
    S.rollouts(inds(j)) = S.rollouts(j);
    S.rollouts(j) = Stemp;
    
end