classdef Agent < handle
    %AGENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        policy;
    end
    
    methods(Abstract)
        
        update(obj, batch_rollouts)

        get_batch_trajectories(obj)    
        
    end
    
end

