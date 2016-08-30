classdef Inexact_Timed_DMP < handle
    
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
        t;
        
        k=1;
        
        lambda = 1;
        
        psi;
        time_normalized_psi;
        bases;
        w;
        eps;
        
        previous_state
        
    end
    
    methods
        
        function obj = Inexact_Timed_DMP(index, dmp_par)
            
            obj.index = index;
            obj.initialize(dmp_par);
        end
        
        function initialize(obj, dmp_par)
            
            obj.initialize_parameters(dmp_par)
            obj.initialize_centers(dmp_par.n_dmp_bf);
            obj.initialize_amplitudes();
        end
        
        function initialize_parameters(obj, dmp_par)
            
            obj.duration = dmp_par.duration;
            obj.tau = 0.5/obj.duration;
            
            obj.goal = dmp_par.goal;
            obj.y0 = dmp_par.start;
            obj.n_rfs = dmp_par.n_dmp_bf;
            
        end
        
        function initialize_centers(obj, n_dmp_bf)
            
            obj.n_rfs = n_dmp_bf;
            
            centers_time = (0:1/(obj.n_rfs-1):1)'*0.5;
            obj.c = exp(-obj.alpha_x*centers_time);
            obj.cd = obj.c*(-obj.alpha_x);
        end
        
        function initialize_amplitudes(obj)
            
            obj.D = (diff(obj.c)*0.55).^2;
            obj.D = 1./[obj.D; obj.D(end)];
        end
                    
        function compute_x(obj)
            
            obj.x(obj.k) = exp(-obj.alpha_x.*obj.tau.*obj.t(obj.k));          
        end
        
        function compute_psi(obj)
            
            for i = 1:obj.n_rfs
                
                obj.psi(obj.k, i) = exp(-0.5*((obj.x(obj.k) - obj.c(i)).^2).*obj.D(i));
            end      
        end
        
        function compute_weighted_psi(obj)
            
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
        
        function compute_bases(obj)
            
            for i = 1:length(obj.t)
                
                obj.bases(i,:) = obj.psi(i,:)*obj.x(i, 1)/sum(obj.psi(i,:));
            end
        end
        
        function [y, yd, ydd] = run_increment(obj, t_block)
            
            if(t_block ==0)
                
                y = obj.previous_state.y;
                yd = obj.previous_state.yd;
                ydd = obj.previous_state.zd * obj.tau;
                
                obj.k = obj.k+1;
                return;
            end
            
            obj.t(obj.k) = t_block;
            dt = obj.t(obj.k) - obj.t(obj.k-1);
            p_state = obj.previous_state;
            
            obj.compute_x;
            obj.compute_psi;
            
            f = sum(obj.x(obj.k) * (obj.w + obj.eps) .* obj.psi(obj.k, :)')...
                /sum(obj.psi(obj.k, :) + 1.e-10);
            f = f * obj.scale;
            
            zd = (obj.alpha_z * (obj.beta_z * (obj.goal - p_state.y) - p_state.yd) + f) * obj.tau;
            ydd = p_state.zd * obj.tau;
            yd = p_state.zd * dt + p_state.yd;
            y = p_state.yd * dt * obj.tau + p_state.y;
            
            yd = yd * obj.tau;
            
            obj.previous_state.y = y;
            obj.previous_state.yd = yd;    
            obj.previous_state.zd = zd;
            
            obj.k = obj.k + 1;
        end
        
        function init_run(obj, eps)
            
            obj.eps = eps;
            
            obj.k = 1; 
            clear obj.t obj.x obj.psi obj.time_normalized_psi obj.bases;
            
            obj.t = 0;
            
            obj.compute_x();
            obj.compute_psi();
            
            obj.previous_state.y = obj.y0;
            obj.previous_state.yd = 0;
            
            f = sum(obj.x(obj.k) * (obj.w + obj.eps) .* obj.psi(obj.k, :)')...
                /sum(obj.psi(obj.k, :) + 1.e-10);
            f = f * obj.scale;
            
            obj.previous_state.zd = ...
                (obj.alpha_z * (obj.beta_z * (obj.goal - obj.previous_state.y) - obj.previous_state.yd) + f) * obj.tau;                    
        end               
    end
end

