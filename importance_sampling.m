function [ S ] = importance_sampling( S, R, n_reuse )
% reuse of roll-out: the n_reuse best trials and re-evalute them the
% next update in the spirit of importance sampling

[~,inds]=sort(sum(R,1));
for j=1:n_reuse,
    Stemp = S.rollouts(j);
    S.rollouts(j) = S.rollouts(inds(j));
    S.rollouts(inds(j)) = Stemp;
end

end

