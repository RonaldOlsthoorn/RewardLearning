classdef SimpleFeatureBlock < reward.FeatureBlock
    
    properties
    end
    
    methods

        function obj = SimpleFeatureBlock(reference)
            obj.reward_primitives = reward.RewardPrimitiveSquaredErrorTool(reference);
        end
    end
end

