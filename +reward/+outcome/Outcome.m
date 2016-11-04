classdef Outcome < handle
    % OUTCOME feature function is a candidate
    % reward function.
    
    properties
    end
    
    methods(Abstract)
        outcome = compute_outcome(Rollout);
    end
    
    methods
        
        function outcomes = batch_compute_outcome(sample_batch)
            % returns a batch of outcomes, results of the reward
            % primitives.
            
            for i=length(sample_batch)
                outcomes(i) = compute_outcome(sample_batch);
            end
        end
    end
end

