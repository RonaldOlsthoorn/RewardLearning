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
        
        int=0;
    end
    
    methods
        
        % Constructor.
        % p: proportional term.
        % i: integral term.
        % d: derivative term.
        function obj = ControllerPID(p, i, d)
            
            obj.Kp = p;
            obj.Ki = i;
            obj.Kd = d;
        end
        
        % Implements pid control law.
        % r: reference position
        % r_d: reference velocity
        % x: position
        % v: velocity
        % control_input: control action.
        function control_input = control_law(obj, r, r_d, x, v)
            
           control_input_raw = obj.Kp*(r-x)+obj.Kd*(r_d-v);
           control_input = obj.saturation(control_input_raw);      
        end
        
        % Update integral state.
        % r: reference position
        % v: reference velocity
        function update_int(obj, r, x)
            
           obj.int = obj.int+(r-x);           
        end
        
        % reset integral term  
        function reset(obj)
          
            obj.int = 0;
        end
        
        % saturation filter. Sets each control input outside 
        % -saturation > control_input_raw || saturation < control_input_raw
        % to saturation value.
        % control_input_raw: unsaturated control input.
        % control_input: saturated control input.
        function control_input = saturation(obj, control_input_raw)
           
            for i = 1:length(control_input_raw)
                
                if control_input_raw(i)< -obj.sat
                    control_input_raw(i) = -obj.sat;
                    disp('Saturation!!!');
                elseif control_input_raw(i)> obj.sat
                    control_input_raw(i) = obj.sat;
                    disp('Saturation!!!');
                end
            end
            
            control_input = control_input_raw;                   
        end
    end
    
end

