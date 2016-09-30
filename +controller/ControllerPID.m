classdef ControllerPID < handle
   
    properties(Constant)
       
        sat = 0.2;
    end
        
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
        
        function control_input = control_law(obj, r, r_d, x, v)
            
           control_input_raw = obj.Kp*(r-x)+obj.Kd*(r_d-v);
           control_input = obj.saturation(control_input_raw);
           
        end
        
        function control_input = saturation(obj, control_input)
           
            for i = 1:length(control_input)
                
                if control_input(i)< -obj.sat
                    control_input(i) = -obj.sat;
                elseif control_input(i)> obj.sat
                    control_input(i) = obj.sat;
                end
            end
                     
        end
    end
    
end

