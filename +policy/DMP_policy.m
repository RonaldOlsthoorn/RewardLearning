classdef DMP_policy < policy.Policy
% implements the policy as a trajectory generator.

    properties
        
        n_rfs;
        n_dof;
        DoFs;
        reference;
        
        init_state;
    end
    
    methods
        
        function obj = DMP_policy(policy_par, ref)
            
            obj.reference = ref;
            obj.n_dof = policy_par.dof;
            obj.n_rfs = policy_par.n_rbfs;
            
            obj.init_state = ref.init_state; % TODO: remove. need for ik.
            
            for i = 1:policy_par.dof
                
                if i ==1 % Annoying MATLAB pre-allocation thingy
                    obj.DoFs = policy.DMP_trajectory(i, policy_par);
                else
                    obj.DoFs(i) = policy.DMP_trajectory(i, policy_par);
                end
                
                % obj.DoFs(i).batch_fit(obj.reference.r_joints(i,:)');
            end
        end
        
        % Return the prescribed trajectory in joint-space.        
        function [trajectory] = create_trajectory(obj, eps)
            
            trajectory = rollout.Rollout();
            
            n_system_dof = 2;
            n_time = length(obj.reference.t);
            
            for i = 1:obj.n_dof
                
                [y, yd, ydd] = obj.DoFs(i).create_trajectory(eps(:,i));
                xd = [y; yd; ydd];
                dof.xd = xd;
                dof.eps = (eps(:,i)*ones(1, length(obj.reference.t)))';
                dof.theta_eps = (obj.DoFs(i).w*ones(1, length(obj.reference.t))+...
                    eps(:,i)*ones(1, length(obj.reference.t)))';
                
                policy.dof(i) = dof;
            end
            
            r = zeros(n_system_dof, n_time);
            rd = zeros(n_system_dof, n_time);
            rdd = zeros(n_system_dof, n_time);
     
            for i=1:n_system_dof
                
                r(i,:) = policy.dof(i).xd(1,:);
                rd(i,:) = policy.dof(i).xd(2,:);
                rdd(i,:) = policy.dof(i).xd(3,:);
            end
            
            policy.r = r;
            policy.rd = rd;
            policy.rdd = rdd;
            
            trajectory.policy = policy;
            trajectory.time = obj.reference.t;
        end
        
        % Return a noiseless trajectory in joint-space.
        function [trajectory] = create_noiseless_trajectory(obj)
            
            eps = zeros(obj.n_rfs, obj.n_dof);
            trajectory = obj.create_trajectory(eps);
        end
        
        % Update the policy.        
        function update(obj, dtheta)
            
            for i = 1:obj.n_dof
                
                obj.DoFs(i).w = obj.DoFs(i).w + dtheta(i,:)';
            end
        end
    end
end