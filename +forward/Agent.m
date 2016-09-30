classdef Agent < handle
    %AGENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        policy;
    end
    
    methods(Abstract)
        
        update_policy(obj, batch_rollouts)

        create_batch_trajectories(obj)    
        
    end
    
end

