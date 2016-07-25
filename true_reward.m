function [ R ] = true_reward( S )
% Returns the true reward, aka expert rating.
% S: struct containing rollout samples.

true_weights = [0.5;0.5;0;0];

% Computes the reward of the batch of roll-outs in S.
% compute all costs in batch from, as this is faster vectorized math in matlab
outcomes = compute_outcomes(S);

R = true_weights'*outcomes; 

end

