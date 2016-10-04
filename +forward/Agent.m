classdef Agent < handle
    %AGENT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        policy;
    end
    
    methods(Abstract)
        
        update(obj, batch_rollouts)
        batch_trajectories = get_batch_trajectories(obj) 
        trajectory = get_noiseless_trajectory(obj)
    end
    
end

