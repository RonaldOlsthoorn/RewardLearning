classdef DMP < handle
    
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
        
        min_y;
        max_y;
        ID;
        n_rfs;
        c_order;
        
        x;
        
        goal = 0;
        
        y0;
        A = 0;
        dG = 0;
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
        
        function obj = DMP(index, dmp_par)
            
            obj.index = index;
            obj.initialize(dmp_par);
        end
        
        function initialize(obj, dmp_par)
            
            obj.initialize_parameters(dmp_par)
            obj.initialize_centers(dmp_par.n_dmp_bf);
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
            
            obj.goal = dmp_par.goal;
            obj.n_rfs = dmp_par.n_dmp_bf;
            
        end
        
        function initialize_centers(obj, n_dmp_bf)
            
            import dmp.DMP;
            
            obj.n_rfs = n_dmp_bf;
            
            centers_time = (0:1/(obj.n_rfs-1):1)'*0.5;
            obj.c = exp(-DMP.alpha_x*centers_time);
            obj.cd = obj.c*(-DMP.alpha_x);
        end
        
        function initialize_amplitudes(obj)
            
            obj.D = (diff(obj.c)*0.55).^2;
            obj.D = 1./[obj.D; obj.D(end)];
        end
                    
        function initialize_x(obj)
            
            import dmp.DMP;
            
            obj.x = zeros(length(obj.t), 1);
            obj.x(1) = 1;
            
            for i = 2:length(obj.t)
                obj.x(i) = obj.x(i-1)-DMP.alpha_x.*obj.tau*obj.Ts*obj.x(i-1);
            end
            
            % obj.x = exp(-DMP.alpha_x.*obj.tau.*obj.t);       
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
        
        function [rollout] = run(obj, eps)
            
            import dmp.DMP;
            import rollout.Rollout;
            
            y = zeros(length(obj.t), 1);
            yd = zeros(length(obj.t), 1);
            ydd = zeros(length(obj.t), 1);
            
            for i = 2:length(obj.t)
                
                f = sum(obj.x(i)*(obj.w+eps).*obj.psi(i,:)')/sum(obj.psi(i,:)+1.e-10);
                f = f*obj.scale;
                
                zd = (DMP.alpha_z*(DMP.beta_z*(obj.goal-y(i-1))-yd(i-1))+f)*obj.tau;
                ydd(i) = zd*obj.tau;
                yd(i) = zd*obj.Ts+yd(i-1);
                y(i) = yd(i-1)*obj.Ts*obj.tau+y(i-1);
            end
            
            rollout = Rollout();
            rollout.dmp(obj.index).xd(:,1) = y;
            rollout.dmp(obj.index).xd(:,2) = yd*obj.tau;
            rollout.dmp(obj.index).xd(:,3) = ydd;
        end
        
%         function run_fit()
%                     
%         end
        
        function batch_fit(obj, T, Td, Tdd)
            
            import dmp.DMP;
            
            if (nargin < 3)
                Td = diffnc(T, dt);
            end
            if (nargin < 4)
                Tdd = diffnc(Td, dt);
            end
            
            % the start state is the first state in the trajectory
            obj.y0 = T(1);
            
            s  = 1;  % for fitting a new primitive, the scale factor is always equal to one  
            amp = s;
            Ft  = (Tdd/obj.tau^2-DMP.alpha_z*(DMP.beta_z*(obj.goal-T)-Td/obj.tau)) / amp;
            
            % compute the weights for each local model along the trajectory
            %PSI = exp(-0.5*((obj.x*ones(1,length(obj.c))-ones(length(T),1)*obj.c').^2).*(ones(length(T), 1)*obj.D'));
            
            % compute the regression
            sx2  = sum(((obj.x.^2)*ones(1,length(obj.c))).*obj.psi, 1)';
            sxtd = sum(((obj.x.*Ft)*ones(1,length(obj.c))).*obj.psi, 1)';
            obj.w    = sxtd./(sx2+1.e-10);
                      
        end
        
%         function run_increment()
%             
%         end
        
    end
    
end

