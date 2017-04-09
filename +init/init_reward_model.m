function [ reward_model ] = init_reward_model(reward_model_par, reference)
% Initialise the RL reward model. Can be a static reward function or a GP
% with expert adaptation.
% reference: Reference object used to measure quality of rollouts
% reward_model_par: tuning parameters of the reward model.

switch reward_model_par.type
    
    case 'reward_model_static_lin'
        reward_model = reward.StaticLinearRewardModel(reference);
    case 'reward_model_static_vp'
        reward_model = reward.StaticVPRewardModel(reference);
    case 'reward_model_UR5_static_vp'
        reward_model = reward.UR5StaticVPRewardModel(reference);
    case 'reward_model_gp'
        gp = gp.init_GP(reward_model_par.gp_par);
        reward_model = reward.init_DynamicRewardModel(reference, gp);
    case 'reward_model_multi_gp'
        reward_model = reward.init_MultiGPRewardModel(reference, reward_model_par);
    case 'viapoint_single_gp'
        reward_model = reward.init_VPSingleGPRewardModel(reference, reward_model_par);
    case 'viapoint_multi_gp'
        reward_model = reward.init_VPMultiGPRewardModel(reference, reward_model_par);
    case 'viapoint_var_single_gp'
        reward_model = reward.init_VPVarSingleGPRewardModel(reference, reward_model_par);
    case 'viapoint_var_multi_gp'
        reward_model = reward.init_VPVarMultiGPRewardModel(reference, reward_model_par);
    case 'viapoint_advanced_static'
        reward_model = reward.StaticVPAdvancedRewardModel(reference);
    otherwise
        reward_model = [];
        
end