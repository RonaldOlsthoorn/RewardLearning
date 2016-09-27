classdef RBF_policy < Policy
    
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
        
        ref;
        
    end
    
    methods
        
        function obj = RBF_policy(index, policy_par)
            
            obj.index = index;
            obj.initialize(policy_par);
        end
        
        function initialize(obj, policy_par)
            
            obj.initialize_parameters(policy_par)
            obj.initialize_centers(policy_par.n_dmp_bf);
            obj.initialize_amplitudes();
            obj.initialize_psi();
            obj.initialize_weighted_psi();
            obj.initialize_bases();
        end
        
        function initialize_parameters(obj, policy_par)
            
            obj.Ts = policy_par.Ts;
            obj.duration = policy_par.duration;
            obj.t = (0:obj.Ts:(obj.duration - obj.Ts))';
            
            obj.n_rfs = policy_par.n_dmp_bf;
            obj.w = zeros(policy_par.n_dmp_bf, 1);
            
        end
        
        function initialize_centers(obj, n_dmp_bf)
            
            obj.n_rfs = n_dmp_bf;
            
            centers_time = (0:(obj.duration/(obj.n_rfs-1)):obj.duration)';
            obj.c = centers_time;
        end
        
        function initialize_amplitudes(obj)
            
            obj.D = 3;
        end
        
        function initialize_psi(obj)
            
            for i = 1:obj.n_rfs
                
                obj.psi(:, i) = exp(-0.5*((obj.t - obj.c(i)).^2)*obj.D);
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
                
                obj.bases(i,:) = obj.psi(i,:)/sum(obj.psi(i,:));
            end
        end
        
        function [y, yd] = create_trajectory(obj, eps)
            
            y = (obj.bases*(obj.w+eps))';
            
            if isprop(obj, 'ref')
                y = y+obj.ref';
            end
            
            yd = [0 diff(y)/obj.Ts];
        end
        
        function batch_fit(obj, T)
            
            %                y = T;
            %                X = obj.bases;
            %
            %                obj.w = (X' * X) \ X' * y;
            
            obj.ref = T;          
        end
    end
end

