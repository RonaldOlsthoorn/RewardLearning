function [obj] = init_DynamicRewardModel(reference, gp)
% Initialize multi gp reward model.
obj = reward.DynamicLinearRewardModel();
obj.feature_block = reward.SimpleOutcomeBlock(reference);
obj.batch_demonstrations = db.RolloutBatch();
obj.gp = gp;
end