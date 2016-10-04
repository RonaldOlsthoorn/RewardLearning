classdef RewardModel < handle
    
    properties
        
        feature_block;
    end
    
    methods(Abstract)
        
        reward = compute_reward(outcome);
          
    end
    
    methods
        
        function outcomes = compute_outcomes(obj, rollout)
            
            outcomes = obj.feature_block.compute_outcomes(rollout);
        end
        
        function rollout = add_outcomes_and_reward(obj, rollout)
            
            outcomes = obj.compute_outcomes(rollout);
            reward = obj.compute_reward(outcomes);
            
            rollout.outcomes = outcomes;
            rollout.r = reward;
            
            rollout.R = sum(reward);
        end
    end
end

