classdef RewardPrimitive < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Abstract)
        outcome = compute_outcome(Rollout);
    end
    
    methods
        
        function outcomes = batch_compute_outcome(sample_batch)
            
            for i=length(sample_batch)
                outcomes(i) = compute_outcome(sample_batch);
            end
        end
    end
end

