function [reward_model] = init_VPVarSingleGPRewardModel(reference, reward_model_par)

obj = reward.VPVarSingleGPRewardModel();
obj.feature_block = reward.VPVarSegmentedOutcomeBlock(reference, reward_model_par.n_segments);
obj.batch_demonstrations = db.RolloutBatch();

obj.gp = gp.init_GP(reward_model_par.gp_par);

obj.n_segments = reward_model_par.n_segments;
obj.n = length(reference.t);
obj.init_segments();
reward_model = obj;
end