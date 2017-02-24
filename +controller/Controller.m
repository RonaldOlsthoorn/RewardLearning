classdef Controller < handle
    % Controller base class of all controllers
    % assumption is made for control laws that map 
    % positions and velocities to control action
    
    properties
    end
    
    methods(Abstract)
        
        control_input = control_law(r, r_d, x, v)
    end
    
end