function [ S ] = importance_sampling( S, ro_par, n_reuse )
% reuse of roll-out: the n_reuse best trials and re-evalute them the
% next update in the spirit of importance sampling

R = zeros(S.n_end, ro_par.reps);

for k=1:ro_par.reps
    R(:,k) = S.rollouts(k).R;
end    


sum_r = sum(R,1);
[~,inds]=sort(sum_r);

for j=1:(length(sum_r)-n_reuse),
    Stemp =    S.rollouts(inds(j));
    S.rollouts(inds(j)) = S.rollouts(j);
    S.rollouts(j) = Stemp;
end