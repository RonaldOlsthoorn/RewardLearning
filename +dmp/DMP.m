classdef DMP < Handle
    
    %
    
    properties(Constant)
        
        alpha_z = 25;
        beta_z = alpha_z/4;
        alpha_g = alpha_z/2;
        alpha_x = alpha_z/3;
        alpha_v = alpha_z;
        beta_v = beta_z;
        
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
        
        function initialize(dmp_par)
            
            initialize_parameters(dmp_par)
            initialize_centers(dmp_par.n_dmp_bf);
            initialize_amplitudes();
            initialize_x();
            initialize_psi();
            initialize_weighted_psi();
        end
        
        function initialize_parameters(obj, dmp_par)
            
            obj.Ts = dmp_par.Ts;
            obj.duration = dmp_par.duration;
            obj.tau = obj.duration/2;
            
            obj.goal = dmp_par.goal;
            obj.n_rfs = dmp_par.n_dmp_bf;
            
        end
        
        function initialize_centers(obj, n_dmp_bf)
            
            obj.n_rfs = n_dmp_bf;
            
            centers_time = (0:1/(obj.n_rfs-1):1)'*0.5;
            obj.c = exp(-DMP.alpha_x*centers_time);
            obj.cd = obj.c*(-DMP.alpha_x);
        end
        
        function initialize_amplitudes(obj)
            
            obj.D = (diff(obj.c)*0.55).^2;
            obj.D = 1./[obj.D; obj.D(end)];
        end
        
        function initialize_t(obj, duration, Ts)
            
            obj.t = 0:Ts:(duration - Ts);
        end
        
        
        function initialize_x(obj)
            
            obj.x = exp(-DMP.alpha_x.*obj.tau.*obj.t);
            
        end
        
        function initialize_psi(obj)
            
            obj.psi = exp(-0.5*((obj.x - obj.c).^2).*obj.D);
        end
        
        function initialize_weighted_psi(obj)
            
            % average updates over time
            % the time weighting matrix (note that this done based on the true duration of the
            % movement, while the movement "recording" is done beyond D.duration). Empirically, this
            % weighting accelerates learning (don't know why though).
            N = (length(obj):-1:1)';
            
            % the final weighting vector takes the kernel activation into account
            W = (N*ones(1, obj.n_rfs)).*obj.psi;
            
            % ... and normalize through time
            obj.time_normalized_psi = W./(ones(S.n_end, 1)*sum(W, 1));
        end
        
        function initialize_bases(obj)
            
            obj.bases = (obj.x.*obj.psi)./sum(obj.spi);
        end
        
        function [rollout] = run(obj, eps)
            
            y = zeros(length(obj.t), 1);
            yd = zeros(length(obj.t), 1);
            ydd = zeros(length(obj.t), 1);
            
            for i = 2:length(obj.t)
                
                f = sum(obj.x(i)*(obj.w+eps).*obj.psi(i))/sum(obj.psi(i)+1.e-10);
                f = f*obj.scale;
                
                obj.zd = (DMP.alpha_z*(DMP.beta_z*(obj.g-obj.y(i-1))-obj.yd(i-1))+f)*obj.tau;
                obj.ydd(i) = obj.zd*obj.tau;
                obj.yd(i) = obj.zd*dt+obj.yd(i-1);
                obj.y(i) = obj.yd(i-1)*obj.dt*obj.tau+obj.y(i-1);
            end
            
            rollout = Rollout();
            rollout.dmp(obj.index).y = y;
            rollout.dmp(obj.index).yd = yd;
            rollout.dmp(obj.index).ydd = ydd;
        end
        
        function run_fit()
            
            
        end
        
        function batch_fit(obj, T, Td, Tdd)
            
            if (nargin < 3)
                Td               = diffnc(T,dt);
            end
            if (nargin < 4)
                Tdd              = diffnc(Td,dt);
            end
            
            % the start state is the first state in the trajectory
            obj.y0 = T(1);
            g  = T(end);
            
            % compute the hidden states
            X = zeros(size(T));
            V = zeros(size(T));
            G = zeros(size(T));
            x = 1;
            v = 0;
            
            for i=1:length(T),
                
                X(i) = x;
                V(i) = v;
                G(i) = g;
                
                
                vd   = 0;
                xd   = DMP.alpha_x*(0-x)*tau;
                                
                x    = xd*dt+x;
                v    = vd*dt+v;                
            end
            
            s  = 1;  % for fitting a new primitive, the scale factor is always equal to one
            
            amp = s;
            Ft  = (Tdd/obj.tau^2-DMP.alpha_z*(DMP.beta_z*(G-T)-Td/obj.tau)) / amp;
            
            % compute the weights for each local model along the trajectory
            PSI = exp(-0.5*((X*ones(1,length(obj.c))-ones(length(T),1)*obj.c').^2).*(ones(length(T),1)*obj.D'));
            
            % compute the regression
            obj.sx2  = sum(((X.^2)*ones(1,length(obj.c))).*PSI,1)';
            obj.sxtd = sum(((X.*Ft)*ones(1,length(obj.c))).*PSI,1)';
            obj.w    = obj.sxtd./(obj.sx2+1.e-10);
                      
        end
        
        function run_increment()
            
        end
        
    end
    
end

