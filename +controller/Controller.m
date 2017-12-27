classdef Controller < handle
    % Controller base class of all controllers.
    % Assumption is made for control laws that map 
    % positions and velocities to control action.
    % $Author: R.M. Olsthoorn $     $Date: 2017/04/08$      $Version: 4.5 $
    
    properties
    end
    
    methods(Abstract)
        
        control_input = control_law(obj, r, r_d, x, v)
        reset(obj);  % used to reset state of the controller.
    end
     
end