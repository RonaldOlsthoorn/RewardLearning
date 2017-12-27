function [reward_model] = init_VPSingleGPRewardModel(reference, reward_model_par)
% initialize single gp reward model for trajectory tracking.

obj = reward.VPSingleGPRewardModel();
obj.feature_block = reward.VPSegmentedOutcomeBlock(reference, reward_model_par.n_segments);
obj.batch_demonstrations = db.RolloutBatch();

obj.gp = gp.init_GP(reward_model_par.gp_par);

obj.n_segments = reward_model_par.n_segments;
obj.n = length(reference.t);
obj.init_segments();
reward_model = obj;
end