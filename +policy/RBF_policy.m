classdef RBF_policy < policy.Policy
    
    properties
        
        n_rfs;
        n_dof;
        DoFs;
        reference;
    end
    
    methods
        
        function obj = RBF_policy(policy_par, ref)
            
            obj.reference = ref;
            obj.n_dof = policy_par.dof;  
            obj.n_rfs = policy_par.n_rbfs;
                        
            for i = 1:policy_par.dof
                
                if i ==1 % Annoying MATLAB pre-allocation thingy
                    obj.DoFs = policy.RBF_trajectory(i, policy_par);
                else
                    obj.DoFs(i) = policy.RBF_trajectory(i, policy_par);
                end
                
                obj.DoFs(i).batch_fit(obj.reference.r_joints(i,:)');
            end           
        end
        
        function [trajectory] = create_trajectory(obj, eps)
            
            trajectory = rollout.Rollout();
            
            for i = 1:obj.n_dof
                
                [y, yd] = obj.DoFs(i).create_trajectory(eps(:,i));
                xd = [y; yd];
                dof.xd = xd;
                dof.eps = (eps(:,i)*ones(1, length(obj.reference.t)))';
                dof.theta_eps = (obj.DoFs(i).w*ones(1, length(obj.reference.t))+...
                                    eps(:,i)*ones(1, length(obj.reference.t)))';  
                
                policy.dof(i) = dof;
                
            end
            
            trajectory.policy = policy;
        end     
        
        function [trajectory] = create_noiseless_trajectory(obj)
            
            eps = zeros(obj.n_rfs, obj.n_dof); 
            trajectory = obj.create_trajectory(eps);
        end
        
        function update(obj, dtheta) 
            
            for i = obj.n_dof
                
                obj.DoFs(i).w = obj.DoFs(i).w + dtheta(i,:)';               
            end            
        end
    end
end
    
