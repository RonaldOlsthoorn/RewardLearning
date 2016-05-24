function [ S ] = compute_reward( S, ro_par, rm )
%Computes the reward of the batch of roll-outs in S.
outcomes = compute_outcomes(S, ro_par);

% compute all costs in batch from, as this is faster vectorized math in matlab
weights(1,1,:) = rm.weights;
weights = repmat(weights, [S.n_end ro_par.reps 1]);

R = sum(weights.*outcomes,3);    

for k = 1:ro_par.reps,
   
    S.rollouts(k).outcomes = outcomes(:,k);
    S.rollouts(k).R        = R(:,k);
    
end


