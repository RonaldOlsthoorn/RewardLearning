classdef ControllerInvKinPerfect < handle
    % ControllerInvKinPerfect uses the inverse of the kinematic model
    % to compute the control action.
    
    properties(Constant)
        
        sat = 1;
    end
    
    properties
        
        par;
        
        Kd = eye(2);
        Kp = .10*eye(2);        
    end
    
    methods
        
        % Constructor.
        % system: parameters describing the system dynamics. Used for
        % inverse dynamics equations.
        function obj = ControllerInvKinPerfect(~, system)
            
            obj.par = system.par;
        end
        
        % Controller for trajectory tracking. Combination of
        % feed-forward (inverted EoM) and feedback control.
        % r: reference end effector position
        % rd: reference end effector velocity
        % rdd: reference end effector acceleration
        % x: end effector position
        % v: end effector velocity
        function [control_input] = control_law(obj, r, rd, rdd, x, v)

            alpha = obj.par.Iz1+obj.par.Iz2+obj.par.m1*obj.par.r1^2 + obj.par.m2*(obj.par.l1^2 + obj.par.r2^2);
            beta = obj.par.m2*obj.par.l1*obj.par.r2;
            delta = obj.par.Iz2 + obj.par.m2*obj.par.r2^2;
            
            M = [alpha+2*beta*cos(x(2,:)), delta+beta*cos(x(2,:))
                delta+beta*cos(x(2,:)), delta];         % Mass matrix
            
            C = [-beta*sin(x(2,:))*v(2,:)+obj.par.b1, -beta*sin(x(1,:))*(v(1,:)+v(2,:))
                beta*sin(x(2,:))*v(1,:), obj.par.b2];       % Coriolis and damping matrix
            
            G = [obj.par.m1*obj.par.g*obj.par.r1*cos(x(1,:))+obj.par.m2*obj.par.g*(obj.par.l1*cos(x(1,:))+obj.par.r2*cos(x(1,:)+x(2,:)))
                2*obj.par.m2*obj.par.g*obj.par.r2*cos(x(1,:)+x(2,:))];     % Gravity matrix
            
            r_acc = [rdd(1,:); rdd(2,:)];
            r_vel = [rd(1,:); rd(2,:)];
            r_pos = [r(1,:); r(2,:)];
            
            x_vel = [v(1,:); v(2,:)];
            x_pos = [x(1,:); x(2,:)];
            
            ff  = M*r_acc+C*r_vel+G;
            
            fb = obj.Kp*(r_pos-x_pos)+obj.Kd*(r_vel-x_vel);
            
            control_input = ff+fb;
        end
        
        % Saturation filter. Sets each control input outside 
        % -saturation > control_input_raw || saturation < control_input_raw
        % to saturation value.
        % control_input_raw: unsaturated control input.
        % control_input: saturated control input.
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
        
        % State-less controller. Nothing to reset.
        function reset(~)        
        end
    end 
end