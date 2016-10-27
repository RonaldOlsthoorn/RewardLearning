classdef PI2AgentBB < forward.Agent
    %PI2Agent defines a PI2 reinforcement learning agent.

    properties
                
        previous_batch;
        noise_mult = 1;
        noise_std;
        annealer;
        reps;
        n_reuse;
    end
    
    methods
        
        function obj = PI2AgentBB(agent_par, p)
            
            obj.policy = p;
            obj.noise_std = agent_par.noise_std;
            obj.annealer = agent_par.annealer;
            obj.reps = agent_par.reps;
            obj.n_reuse = agent_par.n_reuse;
            
            rng(10); % fix random seed. handy for comparisson
        end
        
        % returns the noiseless input trajectory of the agents' 
        % current policy
        function trajectory = get_noiseless_trajectory(obj)
            
            trajectory = obj.policy.create_noiseless_trajectory();             
        end
        
        % returns a batch of input trajectories for the environment to 
        % run.
        function batch_trajectories = get_batch_trajectories(obj)
            
            if isempty(obj.previous_batch), % first batch
                batch_size = obj.reps;
                batch_trajectories = obj.create_batch_trajectories(batch_size);
                return;
            else
                batch_size = obj.reps - obj.n_reuse;
                batch_trajectories = obj.create_batch_trajectories(batch_size);
                return;
            end
        end
        
        % returns a batch of input trajectories. 
        function batch_trajectories = create_batch_trajectories(obj, batch_size)
            
            batch_trajectories = db.RolloutBatch();
            
            for i = 1:batch_size
                
                eps = obj.gen_epsilon();
                ro = obj.policy.create_trajectory(eps); % push back storage policy to policy
                
                batch_trajectories.append_rollout(ro);
            end
        end
        
        % returns a batch of rollouts that mixes the best n_reuse rollouts
        % with the batch of new rollouts.
        function batch_rollouts = mix_previous_rollouts(obj, batch_rollouts)
            
            if isempty(obj.previous_batch)
                return;
            end
            
            batch_rollouts.append_batch(obj.previous_batch);
        end
        
        % update the policy (wrapper)
        function update(obj, batch_rollouts)
            
            update_PI2(obj, batch_rollouts);
        end
        
        % update the policy
        function update_PI2(obj, batch_rollouts)
            
            dtheta = obj.get_PI2_update(batch_rollouts);
            
            % and update the parameters.
            obj.policy.update(dtheta);
            
            obj.importance_sampling(batch_rollouts)
            obj.update_exploration_noise();   
        end
        
        % returns the change in policy parameters per sample. This
        % per-sample distinction is needed for the reward learning update
        function [dtheta] = get_PI2_update(obj, batch_rollouts )
            
            % returns the new policy, based on the new set of roll-outs.
            % S is the data structure of all roll outs.       
            n_dof = obj.policy.n_dof;
            n_rbfs = obj.policy.n_rfs;
            
            n_reps = batch_rollouts.size; % number of roll-outs
            
            P = obj.get_probability_trajectories(batch_rollouts);
            
            % compute the projected noise term. It is computationally more efficient to break this
            % operation into inner product terms.
            Peps = zeros(n_dof, n_reps, n_rbfs);
            
            for j=1:n_dof,
                for k=1:n_reps,
                    Peps(j,k,:) = P(k,:).*(batch_rollouts.get_rollout(k).policy.dof(j).theta_eps(end,:)-obj.policy.DoFs(j).w');
                    %Peps(j,k,:) = P(k,:).*batch_rollouts.get_rollout(k).policy.dof(j).eps(end,:);
                end
            end
            
            % compute the parameter update per time step
            dtheta = squeeze(sum(Peps,2));
        end
        
        % Returns the probability of a sample relative to the other samples
        % in the batch according to the reward.
        function [P] = get_probability_trajectories(~, batch_rollouts)
            
            n_reps = batch_rollouts.size;       % number of roll-outs           
            R_cum = zeros(n_reps, 1);
            
            for k=1:n_reps
                R_cum(k,1) = -batch_rollouts.get_rollout(k).R;
            end
            
            % compute the exponentiated cost with the special trick to automatically
            % adjust the lambda scaling parameter
            maxS = max(R_cum);
            minS = min(R_cum);
            
            h = 10; % this is the scaling parameters in side of the exp() function (see README.pdf)
            expS = exp(-h*(R_cum - minS)./...
                ((maxS-minS+1e-20)));
            
            % the probabilty of a trajectory
            P = expS./(sum(expS));          
        end
        
        % Saves the best n_reuse samples to be reused later on.
        function importance_sampling(obj, batch_rollouts)
            
            R = zeros(obj.reps, 1);
            
            for k=1:obj.reps
                R(k) = batch_rollouts.get_rollout(k).R(1,1);
            end
            
            [~, inds]=sort(R);              
            batch_tmp = db.RolloutBatch();
            
            for j=length(R):-1:(length(R)-obj.n_reuse),
                
                batch_tmp.append_rollout(batch_rollouts.get_rollout(inds(j)));
            end
            
            obj.previous_batch = batch_tmp;
        end
        
        % Update the exploration noise linearly.
        function update_exploration_noise(obj)
            
            obj.noise_mult = max([0.1, obj.noise_mult*obj.annealer]);             
        end
        
        % Generate exploration noise.
        function eps = gen_epsilon(obj)
            
            eps = zeros(obj.policy.n_rfs, obj.policy.n_dof);
            
            for j=1:obj.policy.n_dof,
                std_eps = obj.noise_std(j) * obj.noise_mult;
                eps(:,j) = std_eps*randn(obj.policy.n_rfs, 1);
            end
        end
    end
end