classdef SimpleFeatureBlock < reward.FeatureBlock
    % SIMPLEFEATUREBLOCK feature block containing only squared error.
    
    properties
    end
    
    methods

        function obj = SimpleFeatureBlock(reference)
            obj.reward_primitives = reward.primitive.RewardPrimitiveSquaredErrorTool(reference);
        end
    end
end

