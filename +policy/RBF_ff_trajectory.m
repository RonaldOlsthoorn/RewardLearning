classdef RBF_ff_trajectory < handle
% class describing a feed-forward signal using radial basis functions.

    properties(Constant)
        
        bw_scale = 0.55;
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
        
        ref;
    end
    
    methods
        
        function obj = RBF_ff_trajectory(index, policy_par)
            
            obj.index = index;
            obj.initialize(policy_par);
        end
        
        function initialize(obj, policy_par)
            
            obj.initialize_parameters(policy_par)
            obj.initialize_centers(policy_par.n_rbfs);
            obj.initialize_amplitudes();
            obj.initialize_psi();
            obj.initialize_weighted_psi();
            obj.initialize_bases();
        end
        
        % initializes basic parameters of the trajectory.
        function initialize_parameters(obj, policy_par)
            
            obj.Ts = policy_par.Ts;
            obj.duration = policy_par.duration;
            obj.t = (0:obj.Ts:(obj.duration - obj.Ts))';
            
            obj.n_rfs = policy_par.n_rbfs;
            obj.w = zeros(policy_par.n_rbfs, 1);    
        end
        
        % determine the centers of the basis functions (time-space).
        function initialize_centers(obj, n_rbfs)
            
            obj.n_rfs = n_rbfs;
            
            centers_time = (0:(obj.duration/(obj.n_rfs-1)):obj.duration)';
            obj.c = centers_time;
        end
        
        % amplitude of the basis functions.
        function initialize_amplitudes(obj)
            
            obj.D = 3*ones(length(obj.c),1);
            
            %             obj.D = (diff(obj.c)*obj.bw_scale).^2;
            %             obj.D = 1./[obj.D; obj.D(end)];
        end
        
        % pre compute basis functions.
        function initialize_psi(obj)
            
            for i = 1:obj.n_rfs
                
                obj.psi(:, i) = exp(-0.5*((obj.t - obj.c(i)).^2)*obj.D(i));
            end
        end
        
        % pre compute the weighted basis functions.
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
        
        % pre compute normalized basis functions.
        function initialize_bases(obj)
            
            for i = 1:length(obj.t)
                
                obj.bases(i,:) = obj.psi(i,:)/sum(obj.psi(i,:));
            end
        end
        
        % returns resulting trajectory given exploration noise.
        function [y, yd, ydd] = create_trajectory(obj, eps)
            
            y = (obj.bases*(obj.w+eps))';
            y = y+obj.ref';
            
            yd = [0 diff(y)/obj.Ts];
            
            ydd = [0 diff(yd)/obj.Ts];
        end
        
        function set_ref(obj, T)
            
            obj.ref = T;
        end
    end
end

