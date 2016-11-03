classdef PI2AgentLegacy < forward.Agent
    %PI2Agent defines a PI2 reinforcement learning agent.

    properties
        
        iteration = 1; %unfortunately needed to save this.
        
        previous_batch;
        noise_mult = 1;
        noise_std;
        annealer;
        reps;
        n_reuse;
    end
    
    methods
        
        function obj = PI2AgentLegacy(agent_par, p)
            
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
            
            if isempty(obj.previous_batch) % first batch
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
                ro.iteration = obj.iteration;
                ro.index = i;
                
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
            
            dtheta_per_sample = obj.get_PI2_update_per_sample(batch_rollouts);
            dtheta = squeeze(sum(dtheta_per_sample, 2));
            
            % and update the parameters.
            obj.policy.update(dtheta);
            
            obj.iteration = obj.iteration + 1; %try to remove this later on
            obj.importance_sampling(batch_rollouts)
            obj.update_exploration_noise();
            
        end
        
        % returns the change in policy parameters per sample. This
        % per-sample distinction is needed for the reward learning update
        function [dtheta_per_sample] = get_PI2_update_per_sample(obj, batch_rollouts )
            
            % returns the new policy, based on the new set of roll-outs.
            % S is the data structure of all roll outs.
            
            n_dof = obj.policy.n_dof;
            n_rbfs = obj.policy.n_rfs;
            
            n_reps = batch_rollouts.size; % number of roll-outs
            n_end = length(batch_rollouts.get_rollout(1).policy.dof(1).xd(1,:));           % final time step
            
            P = obj.get_probability_trajectories(batch_rollouts);
            
            % compute the projected noise term. It is computationally more efficient to break this
            % operation into inner product terms.
            PMeps = zeros(n_dof, n_reps, n_end, n_rbfs);
            
            for j=1:n_dof
                for k=1:n_reps
                    
                    % compute g'*eps in vector form
                    gTeps = sum(obj.policy.DoFs(j).bases.*(batch_rollouts.get_rollout(k).policy.dof(j).theta_eps-ones(n_end,1)*obj.policy.DoFs(j).w'),2);
                    
                    % compute g'g
                    gTg  = sum(obj.policy.DoFs(j).bases.*obj.policy.DoFs(j).bases, 2);
                    
                    % compute P*M*eps = P*g*g'*eps/(g'g) from previous results
                    PMeps(j,k,:,:) = obj.policy.DoFs(j).bases.*((P(:,k).*gTeps./(gTg + 1.e-10))*ones(1,n_rbfs));
                end
            end
            
            % compute the final parameter update for each DMP
            dtheta_per_sample = reshape(sum(PMeps.*repmat(reshape(obj.policy.DoFs(j).time_normalized_psi, [1, 1, n_end, n_rbfs]), ...
                [n_dof n_reps 1 1]), ...
                3), ...
                [n_dof n_reps n_rbfs]);
            
        end
        
        % Returns the probability of a sample relative to the other samples
        % in the batch according to the reward.
        function [P] = get_probability_trajectories(~, batch_rollouts)
            
            n_end = length(batch_rollouts.get_rollout(1).policy.dof(1).xd(1,:)); % final time step
            n_reps = batch_rollouts.size;       % number of roll-outs
            
            R_cum = zeros(n_end, n_reps);
            
            for k=1:n_reps
                R_cum(:,k) = -batch_rollouts.get_rollout(k).r;
            end
            
            % compute the exponentiated cost with the special trick to automatically
            % adjust the lambda scaling parameter
            maxS = max(R_cum,[],2);
            minS = min(R_cum,[],2);
            
            h = 10; % this is the scaling parameters in side of the exp() function (see README.pdf)
            expS = exp(-h*(R_cum - minS*ones(1,n_reps))./...
                ((maxS-minS+1e-20)*ones(1,n_reps)));
            
            % the probabilty of a trajectory
            P = expS./(sum(expS,2)*ones(1,n_reps));
            
        end
        
        % Saves the best n_reuse samples to be reused later on.
        function importance_sampling(obj, batch_rollouts)
            
            R = zeros(obj.reps, 1);
            
            for k=1:obj.reps
                R(k) = batch_rollouts.get_rollout(k).R(1,1);
            end
            
            [~, inds]=sort(R);   
            
            batch_tmp = db.RolloutBatch();
            
            for j=length(R):-1:(length(R)-obj.n_reuse)
                
                batch_tmp.append_rollout(batch_rollouts.get_rollout(inds(j)));
            end
            
            obj.previous_batch = batch_tmp;
        end
        
        % Update the exploration noise linearly.
        function update_exploration_noise(obj)
            
            obj.noise_mult = obj.noise_mult - obj.annealer;
            
        end
        
        % Generate exploration noise.
        function eps = gen_epsilon(obj)
            
            eps = zeros(obj.policy.n_rfs, obj.policy.n_dof);
            
            for j=1:obj.policy.n_dof
                std_eps = obj.noise_std(j) * obj.noise_mult;
                eps(:,j) = std_eps*randn(obj.policy.n_rfs, 1);
            end
        end
    end
end