classdef FeatureBlock < handle
    
    properties
        
        reward_primitives;
    end
    
    methods
        
        function outcomes = compute_outcomes(obj, rollout)
            

            for i = length(obj.reward_primitives)
                outcomes(i,:) = obj.reward_primitives(i).compute_outcome(rollout);
            end
        end
        
        function batch_outcomes = batch_compute_outcomes(batch_rollouts)
            

            for i = length(obj.reward_primitives)
                batch_outcomes(i,:) = obj.reward_primitives(i).batch_compute_outcome(batch_rollout);
            end

        end
    end
end