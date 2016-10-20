classdef ControllerInvKinPerfect < handle
    
    % ControllerPID simple feedback controller
    % Controller extended with a saturation
    properties(Constant)
        
        sat = 1;
    end
    
    properties
        
        
        M;
        C;
        G;
        
        Kd = eye(2);
        Kp = .10*eye(2);
        
    end
    
    methods
        
        function obj = ControllerPID(M, C, G)
            
            obj.M = M;
            obj.C = C;
            obj.G = G;
        end
        
        
        function [control_input] = control_law(obj, r, ~, x, ~)
            % Controller for trajectory tracking. Combination of
            % feed-forward (inverted EoM) and feedback control.
            
            r_acc = [r(3,:); r(6,:)];
            r_vel = [r(2,:); r(5,:)];
            r_pos = [r(1,:); r(4,:)];
            
            x_vel = [x(2,:); x(4,:)];
            x_pos = [x(1,:); x(3,:)];
            
            ff  = obj.M*r_acc+obj.C*r_vel+obj.G;
      
            fb = obj.Kp*(r_pos-x_pos)+obj.Kd*(r_vel-x_vel);
            
            control_input = ff+fb; 
            
            %control_input = obj.saturation(u);
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

