classdef RewardModel < handle
    % Base class for reward models. May be a static reward function or a
    % more elaborate reward model. The use of a feature block is enforced.
    
    properties(Constant)
        
        figID = 6;
    end
    
    properties
        
        feature_block;
    end  
    
    methods(Abstract)
        
        rollout = add_reward(obj, rollout);
        print(obj);
    end
    
    methods
        
        % Add outcomes feature functions to rollout.
        function rollout = add_outcomes(obj, rollout)
            
            outcomes = obj.feature_block.compute_outcomes(rollout);
            rollout.outcomes = outcomes;
        end
        
        % Complements the rollout with reward and the outcomes of
        % reward primitives.
        function rollout = add_outcomes_and_reward(obj, rollout)        
            
            rollout = obj.add_outcomes(rollout);
            rollout = obj.add_reward(rollout);
        end
        
        % Add reward to rollout.
        function batch = add_reward_batch(obj, batch)
            
            for i = 1:batch.size
                
                rollout = obj.add_reward(batch.get_rollout(i));
                batch.update_rollout(rollout);
            end
        end
        
        function r_cum = cumulative_reward(~, r)
            
            r_cum = rot90(rot90(cumsum(rot90(rot90(r)))));
        end
    end
end