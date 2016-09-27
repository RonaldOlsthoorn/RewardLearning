classdef StaticLinearRewardModel < reward.RewardModel
    
    properties(Constant)
        
        weights = [1,1];
    end
    
    methods
        
        function reward = compute_reward(outcome)
            
            reward = obj.weights*outcome;
            
        end
        
    end
    
end

