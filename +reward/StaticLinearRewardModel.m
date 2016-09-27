classdef StaticLinearRewardModel < RewardModel
    
    properties(Constant)
        
        weights = [1,1];
    end
    
    methods
        
        function reward = get_reward(outcome)
            
            reward = obj.weights*outcome;
            
        end
        
    end
    
end

