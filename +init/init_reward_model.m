function [ reward_model ] = init_reward_model(reward_model_par, reference)
% initialise the RL reward model. Can be a static reward function or a GP
% with expert adaptation.
% reference: Reference object used to measure quality of rollouts
% reward_model_par: tuning parameters of the reward model.

if(strcmp(reward_model_par.type, 'reward_model_static_lin'))
    reward_model = reward.StaticLinearRewardModel(reference);
else
    reward_model = [];
end

end


