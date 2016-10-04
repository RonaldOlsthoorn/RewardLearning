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
            
            rng(10);
        end
        
        function trajectory = get_noiseless_trajectory(obj)
            
            trajectory = obj.policy.create_noiseless_trajectory(); % push back storage policy to policy
            
        end
        
        function batch_trajectories = get_batch_trajectories(obj)
            
            if isempty(obj.previous_batch),
                batch_size = obj.reps;
                batch_trajectories = obj.create_batch_trajectories(batch_size);
                return;
            else
                batch_size = obj.reps - obj.n_reuse;
                batch_trajectories = obj.create_batch_trajectories(batch_size);
                return;
            end
            
        end
        
        function batch_trajectories = create_batch_trajectories(obj, batch_size)
            
            batch_trajectories(batch_size) = rollout.Rollout();
            obj.noise_mult
            
            for i = 1:batch_size
                
                eps = obj.gen_epsilon();
                ro = obj.policy.create_trajectory(eps); % push back storage policy to policy
                ro.iteration = obj.iteration;
                ro.index = i;
                
                batch_trajectories(i) = ro;
            end
        end
        
        function batch_rollouts = mix_previous_rollouts(obj, batch_rollouts_new)
            
            if isempty(obj.previous_batch)
                batch_rollouts = batch_rollouts_new;
                return;
            end
            batch_rollouts = [batch_rollouts_new, obj.previous_batch((obj.n_reuse+1):end)];
        end
        
        function update(obj, batch_rollouts)
            
            update_PI2(obj, batch_rollouts);
        end
        
        function update_PI2(obj, batch_rollouts)
            
            dtheta_per_sample = obj.get_PI2_update_per_sample(batch_rollouts);
            dtheta = squeeze(sum(dtheta_per_sample, 2));
            
            % and update the parameters by directly accessing the dmp data structure
            obj.policy.update(dtheta);
            
            obj.iteration = obj.iteration + 1; %try to remove this later on
            obj.importance_sampling(batch_rollouts)
            obj.update_exploration_noise();
            
        end
        
        
        function [dtheta_per_sample] = get_PI2_update_per_sample(obj, batch_rollouts )
            
            % returns the new policy, based on the new set of roll-outs.
            % S is the data structure of all roll outs.
            
            n_dof = obj.policy.n_dof;
            n_rbfs = obj.policy.n_rfs;
            
            n_reps = length(batch_rollouts); % number of roll-outs
            n_end = length(batch_rollouts(1).policy.dof(1).xd(1,:));           % final time step
            
            P = obj.get_probability_trajectories(batch_rollouts);
            
            % compute the projected noise term. It is computationally more efficient to break this
            % operation into inner product terms.
            PMeps = zeros(n_dof, n_reps, n_end, n_rbfs);
            
            for j=1:n_dof,
                for k=1:n_reps,
                    
                    % compute g'*eps in vector form
                    gTeps = sum(obj.policy.DoFs(j).bases.*(batch_rollouts(k).policy.dof(j).theta_eps-ones(n_end,1)*obj.policy.DoFs(j).w'),2);
                    
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
        
        function [P] = get_probability_trajectories(~,batch_rollouts)
            
            n_end = length(batch_rollouts(1).policy.dof(1).xd(1,:));           % final time step
            n_reps = length(batch_rollouts);       % number of roll-outs
            
            R_cum = zeros(n_end, n_reps);
            
            for k=1:n_reps
                R_cum(:,k) = -batch_rollouts(k).r;
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
        
        function importance_sampling(obj, batch_rollouts)
            
            R = zeros(obj.reps, 1);
            
            for k=1:obj.reps
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
            
            eps = zeros(obj.policy.n_rfs, obj.policy.n_dof);
            
            for j=1:obj.policy.n_dof,
                std_eps = obj.noise_std(j) * obj.noise_mult;
                eps(:,j) = std_eps*randn(obj.policy.n_rfs, 1);
            end
        end
    end
    
end