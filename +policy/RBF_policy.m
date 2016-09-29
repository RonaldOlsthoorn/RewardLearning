classdef RBF_policy < policy.Policy
    
    properties
        
        DoFs;
        reference;
    end
    
    methods
        
        function obj = RBF_policy(policy_par, ref)
            
            obj.reference = ref;
            
            for i = 1:policy_par.dof
                DoFs(i) = policy.RBF_trajectory(i, policy_par);
                DoFs(i).batch_fit(obj.reference.r_joints(i,:));
            end           
        end
        
        function [trajectory] = create_trajectory(obj, eps)
            
            trajectory = Rollout();
            
            for i = 1:policy_par.dof
                
                trajectory.policy.dof(i).xd = obj.DoFs(i).create_trajectory(eps);
                trajectory.policy.dof(i).eps = eps;
                trajectory.policy.dof(i).theta_eps = obj.DoFs(i).w+eps;       
            end
        end
        
    end
end
    
