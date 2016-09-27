classdef RBF_policy < Policy
    
    properties
        
        DoFs;
        reference;
    end
    
    methods
        
        function obj = RBF_policy(policy_par, ref)
            
            obj.reference = ref;
            
            for i = 1:policy_par.dof
                DoFs(i) = RBF_trajectory(policy_par, reference.r_joints(i,:));
            end
            
        end
        
        function [trajectory] = get_trajectory(obj, eps)
            
            for i = 1:policy_par.dof
                trajectory(i) = obj.DoFs(i).create_trajectory(eps);
            end
        end
    end
end
    
