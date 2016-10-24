classdef ControllerImperfect < handle
   
    % ControllerPID simple feedback controller
    % Controller extended with a saturation
    properties(Constant)
       
        sat = 1;
    end
        
    properties
        
        Kp = 50;
        Ki = 0.1;
        Kd = 1;        
        
        int=0;
    end
    
    methods
        
        function control_input = control_law(obj, r, r_d, ~, x, v)
            
           control_input = obj.Kp*(r-x)+obj.Ki*obj.int+obj.Kd*(r_d-v);
           obj.update_int(r, x);
           %control_input = obj.saturation(control_input_raw);      
        end
        
        function update_int(obj, r, x)
            
           obj.int = obj.int+(r-x); 
            
        end
        
        function reset(obj)
            
            obj.int = 0;
        end
        
        
        function control_input = saturation(obj, control_input)
           
            for i = 1:length(control_input)
                
                if control_input(i)< -obj.sat
                    control_input(i) = -obj.sat;
                    disp('Saturation!!!');
                elseif control_input(i)> obj.sat
                    control_input(i) = obj.sat;
                    disp('Saturation!!!');
                end
            end
                     
        end
    end
    
end

