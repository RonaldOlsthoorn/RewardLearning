classdef System2DOF < plant.System
    
    properties(Constant)
        
    end
    
    properties
        
        Ts;
        dof = 2;
        
        par;      
        state;
        
        init_state;
        
    end
    
    methods
        
        function obj = System2DOF(system_par)
            
            obj.Ts = system_par.Ts;
            obj.par = system_par.par;
        end
        
        function [joint_position, joint_speed,...
                tool_position, tool_speed] = run_increment(obj, control_input)
            
            [xnext] = obj.f_open_loop(obj.state, control_input);
            
            obj.state = xnext;
            
            joint_position = [xnext(1); xnext(3)];
            joint_speed = [xnext(2); xnext(4)];
            
            x_ef = obj.forward_kinematics(xnext');
            
            tool_position = [x_ef(1); x_ef(3)];
            tool_speed = [x_ef(2); x_ef(4)];
        end
        
        function [xnext] = f_open_loop(obj, x, u)
            % for a single state, x is a row vector,
            %   otherwise it is a matrix with the individual state vectors in rows
            % for a single input u is a row vector (or scalar for SI systems),
            %   otherwise it is a matrix with individual input vectors in rows
            
            t = 0:obj.Ts/2:obj.Ts;
            
            y = obj.ode4_ti(t, x, u);
            y = y(end,:);           % we are only interested in the last value
            
            xnext = y;
        end      
        
        function dx = eompend(obj, x, u)
            % Equations of motion for a double pendulum. Derivations based on Lagrangian.
            % Source: http://divf.eng.cam.ac.uk/birl/pub/Main/Publications/LataniotisC.pdf
                        
            alpha = obj.par.Iz1+obj.par.Iz2+obj.par.m1*obj.par.r1^2 + obj.par.m2*(obj.par.l1^2 + obj.par.r2^2);
            beta = obj.par.m2*obj.par.l1*obj.par.r2;
            delta = obj.par.Iz2 + obj.par.m2*obj.par.r2^2;
            
            M = [alpha+2*beta*cos(x(3,:)), delta+beta*cos(x(3,:))
                delta+beta*cos(x(3,:)), delta];         % Mass matrix
            
            C = [-beta*sin(x(3,:))*x(4,:)+obj.par.b1, -beta*sin(x(3,:))*(x(2,:)+x(4,:))
                beta*sin(x(3,:))*x(2,:), obj.par.b2];       % Coriolis and damping matrix
            
            G = [obj.par.m1*obj.par.g*obj.par.r1*cos(x(1,:))+obj.par.m2*obj.par.g*(obj.par.l1*cos(x(1,:))+obj.par.r2*cos(x(1,:)+x(3,:)))
                2*obj.par.m2*obj.par.g*obj.par.r2*cos(x(1,:)+x(3,:))];     % Gravity matrix
            
            dx = (M)\(u-C*[x(2,:); x(4,:)]-G);
            dx = [x(2,:); dx(1,:); x(4,:); dx(2,:)];
        end     
        
        
        function Y = ode4_ti(obj, tspan, y0, u)
            %ODE4  Solve time-invariant differential equations with a non-adaptive method of order 4.
            %   Y = ODE4(ODEFUN,TSPAN,Y0) with TSPAN = [T1, T2, T3, ... TN] integrates
            %   the system of differential equations y' = f(y) by stepping from T0 to
            %   T1 to TN. Function ODEFUN(Y) must return f(y) in a column vector.
            %   The vector Y0 is the initial conditions at T0. Each row in the solution
            %   array Y corresponds to a time specified in TSPAN.
            %
            %   Y = ODE4(ODEFUN,TSPAN,Y0,P1,P2...) passes the additional parameters
            %   P1,P2... to the derivative function as ODEFUN(T,Y,P1,P2...).
            %
            %   This is a non-adaptive solver. The step sequence is determined by TSPAN
            %   but the derivative function ODEFUN is evaluated multiple times per step.
            %   The solver implements the classical Runge-Kutta method of order 4.
            %
            %   Example
            %         tspan = 0:0.1:20;
            %         y = ode4(@vdp1,tspan,[2 0]);
            %         plot(tspan,y(:,1));
            %     solves the system y' = vdp1(t,y) with a constant step size of 0.1,
            %     and plots the first component of the solution.
            %
            % ACKNOWLEDGMENT: This file is derived from the ode4 function, developed by Mathworks, and
            % downloaded from:
            % http://www.mathworks.com/support/tech-notes/1500/1510.html
            %
            % Modified by Lucian Busoniu: removed time dependence of odefun,
            % and commented out argument verifications for speed
            
            
            % if ~isnumeric(tspan)
            %   error('TSPAN should be a vector of integration steps.');
            % end
            %
            % if ~isnumeric(y0)
            %   error('Y0 should be a vector of initial conditions.');
            % end
            %
            h = diff(tspan);
            % if any(sign(h(1))*h <= 0)
            %   error('Entries of TSPAN are not in order.')
            % end
            
            % try
            %   f0 = feval(odefun,tspan(1),y0,varargin{:});
            % catch
            %   msg = ['Unable to evaluate the ODEFUN at t0,y0. ',lasterr];
            %   error(msg);
            % end
            
            y0 = y0(:);   % Make a column vector.
            % if ~isequal(size(y0),size(f0))
            %   error('Inconsistent sizes of Y0 and f(t0,y0).');
            % end
            
            neq = length(y0);
            N = length(tspan);
            Y = zeros(neq,N);
            F = zeros(neq,4);
            
            Y(:,1) = y0;
            for i = 2:N
                hi = h(i-1);
                yi = Y(:,i-1);
                F(:,1) = obj.eompend(yi,u);
                F(:,2) = obj.eompend(yi+0.5*hi*F(:,1),u);
                F(:,3) = obj.eompend(yi+0.5*hi*F(:,2),u);
                F(:,4) = obj.eompend(yi+hi*F(:,3),u);
                Y(:,i) = yi + (hi/6)*(F(:,1) + 2*F(:,2) + 2*F(:,3) + F(:,4));
            end
            Y = Y.';
        end
        
        function [x_ef] = forward_kinematics(obj, x)
            % Returns the cartesian coordinates of the end effector
            % as function of the state and the parameters.
                        
            x_end       = obj.par.l1*cos(x(1,:))+obj.par.l2*cos(x(1,:)+x(3,:));
            x_vel_end   = -(obj.par.l1*sin(x(1,:))+obj.par.l2*sin(x(1,:)+x(3,:))).*x(2,:)...
                -obj.par.l2*sin(x(1,:)+x(3,:)).*x(4,:);
            y_end       = obj.par.l1*sin(x(1,:))+obj.par.l2*sin(x(1,:)+x(3,:));
            y_vel_end   = (obj.par.l1*cos(x(1,:))+obj.par.l2*cos(x(1,:)+x(3,:))).*x(2,:)...
                +obj.par.l2*cos(x(1,:)+x(3,:)).*x(4,:);
            
            x_ef = [x_end; x_vel_end; y_end; y_vel_end];
        end      
        
        function set_init_state(obj, init_state)
            
            obj.init_state = [init_state(1); 0; init_state(2); 0];
        end
        
        function [output] = reset(obj)
            
            obj.state = obj.init_state;
            output.joint_position = [obj.state(1) ; obj.state(3)];
            output.joint_speed = [obj.state(2) ; obj.state(4)];
        end
        
    end
end
            
            
