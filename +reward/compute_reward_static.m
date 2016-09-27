function [ S ] = compute_reward_static(S, ro_par, rm )
% Computes the reward of a batch of roll-outs.
% S: struct containing all the roll-outs of this iteration.
% ro_par: struct containing all the roll-out parameters.
% rm: struct containing the reward model.

err_squared = reward_err2(S, ro_par);

for k = 1:ro_par.reps,
    S.rollouts(k).r = err_squared(:,k);
end

