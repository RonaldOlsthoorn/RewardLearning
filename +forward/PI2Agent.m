classdef PI2Agent < forward.Agent
    
    properties
        
        iteration = 1;
        
        previous_batch;
        noise_mult = 1;
        noise_std;
        annealer;
        reps;
        n_reuse;
    end
    
    methods
        
        function obj = PI2Agent(agent_par, p)
            
            obj.policy = p;
            obj.noise_std = agent_par.noise_std;
            obj.annealer = agent_par.annealer;
            obj.reps = agent_par.reps;
            obj.n_reuse = agent_par.n_reuse;
        end
        
        function batch_trajectories = get_batch_trajectories(obj)
            
            if isprop(obj, 'previous_batch'),
                batch_size = obj.reps;
                batch_trajectories = obj.create_batch_trajectories(batch_size);
                return;
            else
                batch_size = obj.reps - obj.n_reuse;
                batch_trajectories = [obj.previous_batch(1:obj.n_reuse), ...
                    obj.create_batch_trajectories(batch_size)];
                return;
            end
            
        end
        
        function batch_trajectories = create_batch_trajectories(obj, batch_size)
            
            batch_trajectories(batch_size) = Rollout();
            
            for i = (obj.n_reuse+1):batch_size
                
                eps = obj.gen_epsilon();
                ro = policy.create_trajectory(eps); % push back storage policy to policy
                ro.iteration = obj.iteration;
                ro.index = i;
                
                batch_trajectories(i) = ro;
            end
        end
        
        function dtheta_per_sample = get_PI2_update_per_sample(batch_rollouts)
            
        end
        
        function update_policy(obj, batch_rollouts)
            
            obj.iteration = obj.iteration + 1; %try to remove this later on
            obj.importance_sampling(batch_rollouts)
            obj.update_exploration();
        end
        
        function importance_sampling(obj, batch_rollouts)
            
            R = zeros(forward_par.reps, 1);
            
            for k=1:forward_par.reps
                R(k) = batch_rollouts(k).R(1,1);
            end
            
            [~,inds]=sort(R);
            
            for j=1:(length(R)-obj.n_reuse),
                
                rollout_temp = batch_rollouts(inds(j));
                batch_rollouts(inds(j)) = batch_rollouts(j);
                batch_rollouts(j) = rollout_temp;   
            end          
            
            obj.previous_batch = batch_rollouts;
        end
        
        function update_exploration_noise(obj)
            
            obj.noise_mult = obj.noise_mult - obj.annealer;
            
        end
        
        function eps = gen_epsilon(obj)
            
            for j=1:length(obj.policy.n_dof),
                std_eps = obj.noise_std(j) * ro_par.noise_mult;
                eps = std_eps*randn(policy.n_rfs, 1);
            end
        end
    end
    
end

