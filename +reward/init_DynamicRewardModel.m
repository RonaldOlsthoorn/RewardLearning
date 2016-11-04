function [obj] = init_DynamicRewardModel(reference, gp)

obj = reward.DynamicLinearRewardModel();
obj.feature_block = reward.SimpleOutcomeBlock(reference);
obj.gp = gp;
end