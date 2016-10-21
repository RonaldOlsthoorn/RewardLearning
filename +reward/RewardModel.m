classdef RewardModel < handle
    % Base class for reward models. May be a static reward function or a
    % more elaborate reward model. The use of a feature block is enforced.
    
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
            % Complements the rollout with reward and the outcomes of
            % reward primitives.
            
            outcomes = obj.compute_outcomes(rollout);
            reward = obj.compute_reward(outcomes);
            
            rollout.outcomes = outcomes;
            rollout.r = reward;
            rollout.r_cum = cumulative_reward(r);
            
            rollout.R = sum(reward);
        end
        
        function r_cum = cumulative_reward(r)
           
            
        end
    end
end

