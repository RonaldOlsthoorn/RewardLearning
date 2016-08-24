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
        weighted_psi;
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
            
            rollout = rollout();
            rollout.dmp(obj.index).y = y;
            rollout.dmp(obj.index).yd = yd;
            rollout.dmp(obj.index).ydd = ydd;
            
        end
        
        function run_fit()
            
        end
        
        function batch_fit()
            
        end
        
        function run_increment()
            
        end
        
    end
    
end

