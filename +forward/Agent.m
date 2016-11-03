classdef Agent < handle
    %AGENT Defines a base class for episode based reinforcement learning
    % agents.
    
    properties
        
        policy;
    end
    
    methods(Abstract)
        
        update(obj, batch_rollouts)
        batch_trajectories = get_batch_trajectories(obj) 
        trajectory = get_noiseless_trajectory(obj)
    end
    
end

