classdef ControllerPID < handle
   
    % ControllerPID simple feedback controller
    % Controller extended with a saturation
    properties(Constant)
       
        sat = 1;
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
            
           control_input_raw = obj.Kp*(r-x)+obj.Ki*obj.int+obj.Kd*(r_d-v);
            obj.update_int(r, x);
            control_input = obj.saturation(control_input_raw);      
        end
           
        % update integration term
        function update_int(obj, r, x)
            
           obj.int = obj.int+(r-x);           
        end

        % reset integral term
        function reset(obj)
            obj.int = 0;
        end
        
        % Filter function tha puts a limit on the control input 
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

