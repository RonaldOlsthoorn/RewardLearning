classdef Outcome < handle
    % OUTCOME feature function is a candidate
    % reward function.
    
    properties
    end
    
    methods(Abstract)
        outcome = compute_outcome(Rollout);
    end
    
    methods
        
        % Returns a matrix of outcomes, results of the reward primitives.
        % sample_batch: set of trajectories for which the outcomes have to
        % be computed.
        function outcomes = batch_compute_outcome(sample_batch) 
            
            for i=length(sample_batch)
                outcomes(i) = compute_outcome(sample_batch);
            end
        end
    end
end

