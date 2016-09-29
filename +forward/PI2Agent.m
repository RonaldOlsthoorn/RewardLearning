classdef PI2Agent < forward.Agent
    
    properties
        
        previous_batch;
        noise_mult = 1;
        noise_std;
    end
    
    methods
        
        function obj = PI2Agent(agent_par, p)
            
            obj.policy = p;
            obj.noise_std = agent_par.noise_std;
        end
        
        function batch_trajectories = batch_create_trajectory(obj)
            
            if obj.previous_batch == [],
                
            else
                
            end
             
            eps = obj.gen_epsilon();
            
        end
        
        function dtheta_per_sample = get_PI2_update_per_sample(batch_rollouts)
            
        end
        
        function update_policy(batch_rollouts)
            
            
        end
        
        function importance_sampling(batch_rollouts)
            
            
        end
        
        function eps = gen_epsilon(obj)
            
            for j=1:length(obj.policy.n_dof),
                std_eps = obj.noise_std(j) * ro_par.noise_mult;
                eps = std_eps*randn(policy.n_rfs, 1);           
            end           
        end
    end
    
end

