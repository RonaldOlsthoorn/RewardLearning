classdef FeatureBlock < handle
    
    properties
        
        reward_primitives;
    end
    
    methods
        
        function outcomes = compute_outcomes(obj, rollout)
            
            outcomes = zeros(length(rollout.time), length(obj.reward_primitives));

            for i = length(obj.reward_primitives)
                outcomes(:,i) = obj.reward_primitives(i).compute_outcome(rollout);
            end
        end
        
        
    end
end