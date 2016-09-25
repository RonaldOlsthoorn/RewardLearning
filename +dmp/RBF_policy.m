classdef RBF_policy < handle
    
    %  
    properties(Constant)
        
             
    end
    
    
    properties
        
        index;
        
        n_rfs;

        duration;
        Ts;
        t;
        
        c;
        D;
        
        psi;
        time_normalized_psi;
        bases;
        w;
        
    end
    
    methods
        
        function obj = RBF_policy(index, dmp_par)
            
            obj.index = index;
            obj.initialize(dmp_par);
        end
        
        function initialize(obj, dmp_par)
            
            obj.initialize_parameters(dmp_par)
            obj.initialize_centers(dmp_par.n_dmp_bf);
            obj.initialize_amplitudes();
            obj.initialize_psi();
            obj.initialize_weighted_psi();
            obj.initialize_bases();
        end
        
        function initialize_parameters(obj, dmp_par)
            
            obj.Ts = dmp_par.Ts;
            obj.duration = dmp_par.duration;
            obj.t = (0:obj.Ts:(obj.duration - obj.Ts))';
            
            obj.n_rfs = dmp_par.n_dmp_bf;      
            obj.w = zeros(dmp_par.n_dmp_bf, 1);
        end
        
        function initialize_centers(obj, n_dmp_bf)
            
            obj.n_rfs = n_dmp_bf;
            
            centers_time = (0:1/(obj.n_rfs-1):1)';
            obj.c = centers_time;
        end
        
        function initialize_amplitudes(obj)
            
            obj.D = 0.55;
        end
                    
        function initialize_psi(obj)
            
            for i = 1:obj.n_rfs
                
                obj.psi(:, i) = exp(-0.5*((obj.t - obj.c(i)).^2).*obj.D(i));
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
        
        function [y, yd] = run(obj, eps)
                        
            y = sum((obj.w+eps).*obj.psi(1,:)')/sum(obj.psi(1,:)+1.e-10);
            yd = [0 diff(y)/obj.Ts];
        end
        
        
        function batch_fit(obj, T)
            
            if (nargin < 3)
                Td = diffnc(T, dt);
            end
            if (nargin < 4)
                Tdd = diffnc(Td, dt);
            end
            
            % compute the regression
            sx2  = sum(((obj.x.^2)*ones(1,length(obj.c))).*obj.psi, 1)';
            sxtd = sum(((obj.x.*Ft)*ones(1,length(obj.c))).*obj.psi, 1)';
            obj.w    = sxtd./(sx2+1.e-10);
                      
        end
    end    
end

