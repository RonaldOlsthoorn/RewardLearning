classdef StaticLinearRewardModel < reward.RewardModel
    % STATICLINEARREWARDMODEL: simple reward model based on the squared
    % tracking error of the trajectory.
    
    properties(Constant)
        
        weights = 1;
    end
    
    properties

    end
    
    methods
        
        function obj = StaticLinearRewardModel(reference)
            
            obj.feature_block = reward.SimpleFeatureBlock(reference);
            
        end
        
        function reward = compute_reward(obj, outcomes)
            
            reward = obj.weights*outcomes;
            
        end
        
    end
    
end

