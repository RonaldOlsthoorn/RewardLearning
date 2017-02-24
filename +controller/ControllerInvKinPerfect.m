classdef ControllerInvKinPerfect < handle
    % ControllerInvKinPerfect uses the inverse of the kinematic model
    % to compute the control action.
    
    properties(Constant)
        
        sat = 1;
    end
    
    properties
        
        par
        
        Kd = eye(2);
        Kp = .10*eye(2);
        
    end
    
    methods
        
        function obj = ControllerInvKinPerfect(~, system)
            
            obj.par = system.par;
        end        
        
        function [control_input] = control_law(obj, r, rd, rdd, x, v)
            % Controller for trajectory tracking. Combination of
            % feed-forward (inverted EoM) and feedback control.
            
            alpha = obj.par.Iz1+obj.par.Iz2+obj.par.m1*obj.par.r1^2 + obj.par.m2*(obj.par.l1^2 + obj.par.r2^2);
            beta = obj.par.m2*obj.par.l1*obj.par.r2;
            delta = obj.par.Iz2 + obj.par.m2*obj.par.r2^2;
            
            % Mass matrix
            M = [alpha+2*beta*cos(x(2,:)), delta+beta*cos(x(2,:))
                delta+beta*cos(x(2,:)), delta];         
            
            % Coriolis and damping matrix
            C = [-beta*sin(x(2,:))*v(2,:)+obj.par.b1, -beta*sin(x(1,:))*(v(1,:)+v(2,:))
                beta*sin(x(2,:))*v(1,:), obj.par.b2];       
            
            % Gravity matrix
            G = [obj.par.m1*obj.par.g*obj.par.r1*cos(x(1,:))+obj.par.m2*obj.par.g*(obj.par.l1*cos(x(1,:))+obj.par.r2*cos(x(1,:)+x(2,:)))
                2*obj.par.m2*obj.par.g*obj.par.r2*cos(x(1,:)+x(2,:))];     
            
            r_acc = [rdd(1,:); rdd(2,:)];
            r_vel = [rd(1,:); rd(2,:)];
            r_pos = [r(1,:); r(2,:)];
            
            x_vel = [v(1,:); v(2,:)];
            x_pos = [x(1,:); x(2,:)];
            
            % feedforward term
            ff  = M*r_acc+C*r_vel+G;
            
            % feedback term
            fb = obj.Kp*(r_pos-x_pos)+obj.Kd*(r_vel-x_vel);
            
            control_input = ff+fb;
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
        
        % State-less controller. We do nothing.
        function reset(obj)         
        end
    end 
end