classdef ControllerPID < handle
    
    
    properties
        
        Kp;
        Ki;
        Kd;
        
    end
    
    methods
        
        function obj = ControllerPID(p, i, d)
            
            obj.Kp = p;
            obj.Ki = i;
            obj.Kd = d;
        end
        
        function control_input = control_law(r, r_d, x, v)
            
           control_input = obj.Kp*(r-x)+obj.Kd*(r_d-v);
        end
    end
    
end

