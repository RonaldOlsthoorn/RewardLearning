function [obj] = init_DynamicRewardModel(reference, gp)

obj = reward.DynamicLinearRewardModel();
obj.feature_block = reward.SimpleOutcomeBlock(reference);
obj.batch_demonstrations = db.RolloutBatch();
obj.gp = gp;
end