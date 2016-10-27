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
        
       function rollout = add_outcomes(obj, rollout)
            
            outcomes = obj.compute_outcomes(rollout);
            rollout.outcomes = outcomes;
            rollout.sum_out = sum(outcomes);
       end
        
       function rollout = add_reward(obj, rollout)
            
            reward = obj.compute_reward(rollout.outcomes);
            rollout.r = reward;
            rollout.r_cum = obj.cumulative_reward(reward); 
            rollout.R = sum(reward);
       end 
        
       function rollout = add_outcomes_and_reward(obj, rollout)
            % Complements the rollout with reward and the outcomes of
            % reward primitives.
            
            rollout = obj.add_outcomes(rollout);
            rollout = obj.add_reward(rollout);
       end
        
        function r_cum = cumulative_reward(~, r)
           
            r_cum = rot90(rot90(cumsum(rot90(rot90(r)))));
        end
    end
end

