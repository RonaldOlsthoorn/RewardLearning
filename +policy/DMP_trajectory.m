classdef DMP_trajectory < handle
    
    %
    properties(Constant)
        
        alpha_z = 25;
        beta_z = 25/4;
        alpha_g = 25/2;
        alpha_x = 25/3;
        alpha_v = 25;
        beta_v = 25/4;
    end
    
    properties
        
        index;
        
        n_rfs;
        c_order;
        
        x;
        
        goal = 0;
        y0;
        
        scale = 1;
        
        c; % to be renamed
        cd; % to be renamed
        D; % to be renamed
        
        duration;
        tau;
        Ts;
        t;
        
        lambda = 1;
        
        psi;
        time_normalized_psi;
        bases;
        w;  
    end
    
    methods
        
        function obj = DMP_trajectory(index, dmp_par)
            
            obj.index = index;
            obj.initialize(dmp_par);
        end
        
        function initialize(obj, dmp_par)
            
            obj.initialize_parameters(dmp_par)
            obj.initialize_centers();
            obj.initialize_amplitudes();
            obj.initialize_x();
            obj.initialize_psi();
            obj.initialize_weighted_psi();
            obj.initialize_bases();
        end
        
        function initialize_parameters(obj, dmp_par)
            
            obj.Ts = dmp_par.Ts;
            obj.duration = dmp_par.duration;
            obj.tau = 0.5/obj.duration;
            obj.t = (0:obj.Ts:(obj.duration - obj.Ts))';
            
            obj.goal = dmp_par.goal(obj.index);
            obj.y0 = dmp_par.start(obj.index);

            obj.n_rfs = dmp_par.n_rbfs;    
            obj.w = zeros(obj.n_rfs,1);
        end
        
        function initialize_centers(obj)
                        
            centers_time = (0:1/(obj.n_rfs-1):1)'*0.5;
            obj.c = exp(-obj.alpha_x*centers_time);
            obj.cd = obj.c*(-obj.alpha_x);
        end
        
        function initialize_amplitudes(obj)
            
            obj.D = (diff(obj.c)*0.55).^2;
            obj.D = 1./[obj.D; obj.D(end)];
        end
        
        function initialize_x(obj)
            
            obj.x = zeros(length(obj.t), 1);
            obj.x(1) = 1;
            
            for i = 2:length(obj.t)
                obj.x(i) = obj.x(i-1)-obj.alpha_x.*obj.tau*obj.Ts*obj.x(i-1);
            end
            
            % obj.x = exp(-obj.alpha_x.*obj.tau.*obj.t);
        end
        
        function initialize_psi(obj)
            
            for i = 1:obj.n_rfs
                
                obj.psi(:, i) = exp(-0.5*((obj.x - obj.c(i)).^2).*obj.D(i));
            end
        end
        
        function initialize_weighted_psi(obj)
            
            % average updates over time
            % the time weighting matrix (note that this done based on the true duration of the
            % movement, while the movement "recording" is done beyond D.duration). Empirically, this
            % weighting accelerates learning (don't know why though).
            N = (length(obj.t):-1:1)';
            
            % the final weighting vector takes the kernel activation into account
            W = (N*ones(1, obj.n_rfs)).*obj.psi;
            
            % ... and normalize through time
            obj.time_normalized_psi = W./(ones(length(obj.t), 1)*sum(W, 1));
        end
        
        function initialize_bases(obj)
            
            for i = 1:length(obj.t)
                
                obj.bases(i,:) = obj.psi(i,:)*obj.x(i, 1)/sum(obj.psi(i,:));
            end
            
        end
        
        function [y, yd, ydd] = create_trajectory(obj, eps)
            
            import rollout.Rollout;
            
            y = zeros(length(obj.t), 1);
            yd = zeros(length(obj.t), 1);
            ydd = zeros(length(obj.t), 1);
            
            f = sum(obj.x(1)*(obj.w+eps).*obj.psi(1,:)')/sum(obj.psi(1,:)+1.e-10);
            f = f*obj.scale;
            
            zd = (obj.alpha_z*(obj.beta_z*(obj.goal-y(1))-yd(1))+f)*obj.tau;
            ydd(1) = zd*obj.tau;
            
            for i = 2:length(obj.t)
                
                f = sum(obj.x(i).*(obj.w+eps).*obj.psi(i,:)')/sum(obj.psi(i,:)+1.e-10);
                f = f*obj.scale;
                
                zd = (obj.alpha_z*(obj.beta_z*(obj.goal-y(i-1))-yd(i-1))+f)*obj.tau;
                ydd(i) = zd*obj.tau;
                yd(i) = zd*obj.Ts+yd(i-1);
                y(i) = yd(i-1)*obj.Ts*obj.tau+y(i-1);
            end
            
            y = y';
            yd = (yd.*obj.tau)';
            ydd = ydd';
        end
        
        
        function batch_fit(obj, T, Td, Tdd)
            
            if (nargin < 3)
                Td = obj.diffnc(T, obj.Ts);
            end
            if (nargin < 4)
                Tdd = obj.diffnc(Td, obj.Ts);
            end
            
            % the start state is the first state in the trajectory
            obj.y0 = T(1);
            
            Ft  = (Tdd/obj.tau^2-obj.alpha_z*(obj.beta_z*(obj.goal-T)-Td/obj.tau));
            
            % compute the weights for each local model along the trajectory
            %PSI = exp(-0.5*((obj.x*ones(1,length(obj.c))-ones(length(T),1)*obj.c').^2).*(ones(length(T), 1)*obj.D'));
            
            % compute the regression
            sx2  = sum(((obj.x.^2)*ones(1,length(obj.c))).*obj.psi, 1)';
            sxtd = sum(((obj.x.*Ft)*ones(1,length(obj.c))).*obj.psi, 1)';
            obj.w    = sxtd./(sx2+1.e-10);           
        end
        
        
        function res = diffnc(~, x, dt)
            
            res = [0; diff(x)]./dt;
        end
    end
    
end

