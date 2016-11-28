classdef OutcomeBlock < handle
    % FEATUREBLOCK: manages reward primitives aka feature functions in one
    % concise block and offers the outcomes of the reward primitives.
    
    properties
        
        reward_primitives;
    end
    
    methods
        
        function outcomes = compute_outcomes(obj, rollout)
            % returns the outcome of the reward primitive functions, based
            % on the rollout (Rollout object).
            
            outcomes = zeros(length(rollout.time), length(obj.reward_primitives));

            for i = length(obj.reward_primitives)
                outcomes(:,i) = obj.reward_primitives(i).compute_outcome(rollout);
            end
        end
    end
end