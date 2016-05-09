function [ R ] = compute_reward( S, ro_par, rm_par )
%Computes the reward of the batch of roll-outs in S.
outcomes = compute_outcomes(S, ro_par);

% compute all costs in batch from, as this is faster vectorized math in matlab
weights(1,1,:) = rm_par.weights;
weights = repmat(weights, [S.n_end ro_par.reps 1]);

R = sum(weights.*outcomes,3);    

end

