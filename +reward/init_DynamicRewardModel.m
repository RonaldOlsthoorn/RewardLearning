function [obj] = init_DynamicRewardModel(reference, gp)

obj = reward.DynamicLinearRewardModel();
obj.feature_block = reward.SimpleFeatureBlock(reference);
obj.gp = gp;
end