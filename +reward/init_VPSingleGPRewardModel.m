function [ obj ] = init_VPSingleGPRewardModel(reference, reward_model_par)

obj = reward.DynamicLinearRewardModel();
obj.feature_block = reward.VPOutcomeBlock(reference);
obj.batch_demonstrations = db.RolloutBatch();
obj.gp = gp.init_GP(reward_model_par.gp_par);

end