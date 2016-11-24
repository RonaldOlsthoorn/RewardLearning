function [reward_model] = init_VPMultiGPRewardModel(reference, reward_model_par)

obj = reward.VPMultiGPRewardModel();
obj.feature_block = reward.VPTimeSegmentedOutcomeBlock(reference);
obj.batch_demonstrations = db.RolloutBatch();

for i = 1:reward_model_par.n_segments
    
    gps(i) = gp.init_GP(reward_model_par.gp_par);
end

obj.gps = gps;
obj.n_segments = reward_model_par.n_segments;
obj.n = length(reference.t);
obj.init_segments();
reward_model = obj;
end