classdef DynamicEnvironment < environment.Environment
% Environment with a dynamic reward function (also contains the expert).

    properties
        
        expert;
        agent;
        
        original_batch;
        
        tol; % tolerance for epd
    end
    
    methods
        
        function obj = DynamicEnvironment(p, r, e, a, t)
            
            obj = obj@environment.Environment(p, r);
            obj.expert = e;
            obj.agent = a;
            obj.tol = t;
        end
        
        % Prepares the environment by demonstrating 4 rollouts and
        % initializing the reward function
        function prepare(obj)
            
            rng(20);
            
            obj.index = 1;
            
            % create the controls for the first batch of rollouts
            batch_trajectory = obj.agent.create_batch_trajectories(4);
            % run em
            batch_trajectory = obj.plant.batch_run(batch_trajectory);
            % allocate new batch (batch_trajectory is index-less)
            batch_rollouts = db.RolloutBatch();
            
            for i = 1:batch_trajectory.size
                
                rollout = batch_trajectory.get_rollout(i);
                rollout.iteration = obj.iteration;
                rollout.index = obj.index;
                obj.index = obj.index + 1;
                
                rollout = obj.reward_model.add_outcomes(rollout);
                
                rollout.R_expert = obj.expert.query_expert(rollout);
                batch_rollouts.append_rollout(rollout);
            end
            
            obj.iteration = obj.iteration + 1;
            
            obj.reward_model.add_batch_demonstrations(batch_rollouts);
            obj.reward_model.print();
            
            rng(10);
        end
        
        % wrapper function for reward update
        function update_reward(obj, batch_rollouts)
            
            obj.update_reward_epd(batch_rollouts);
        end
        
        % Updates the reward if needed by demonstrating rollouts of the
        % batch if this is beneficial according to the epd acquisition
        % function.
        function update_reward_epd(obj, batch_rollouts)
            
            obj.original_batch = batch_rollouts;
            unqueried_batch = batch_rollouts.copy();
            
            find_nominee = true;   
            
            while true == find_nominee
                
                [max_rollout, max_epd] = obj.find_max_acquisition(unqueried_batch);
                
                %disp(strcat('max epd: ', num2str(max_epd)));
                
                % rollouts are reused! therefore always check if rollout
                % already queried.
                if(~obj.reward_model.batch_demonstrations.contains(max_rollout) && max_epd > obj.tol)
                    rollout = obj.demonstrate_and_query_expert(max_rollout);
                    obj.reward_model.add_demonstration(rollout);
                    obj.reward_model.print();
                    unqueried_batch.delete(max_rollout);
                    
                    if unqueried_batch.is_empty()
                        find_nominee = false;
                    end
                else
                    find_nominee = false;
                end
            end
        end
        
        function [rollout] = demonstrate_rollout(obj, sample)
            
            disp('demonstrate rollout');
            rollout = obj.plant.run(sample);
        end
        
        function rollout = demonstrate_and_query_expert(obj, sample)
            
            rollout = obj.demonstrate_rollout(sample);
            rollout.R_expert = obj.expert.query_expert(rollout);          
        end
        
        function [max_rollout, max_epd] = find_max_acquisition(obj, batch_rollouts)
            
            max_rollout = batch_rollouts.get_rollout(1);
            max_epd = obj.epd(max_rollout);
            
            if batch_rollouts.size ==1
                return;
            end
            
            for i = 2:batch_rollouts.size
                
                epd_candidate = obj.epd(batch_rollouts.get_rollout(i));
                
                if epd_candidate > max_epd
                    max_rollout = batch_rollouts.get_rollout(i);
                    max_epd = epd_candidate;
                end
            end
        end
        
        function res = epd(obj, rollout)
            
            [m, s2] = obj.reward_model.gp.assess(sum(rollout.outcomes));
            sigma_points = m(end) + [1 -1]*s2(end);
            
            epd = zeros(1, 2);         
            theta_tilda = obj.agent.get_probability_trajectories(obj.original_batch);
            
            for sigma = 1:length(sigma_points)
                
                batch = obj.original_batch.copy();              
                rollout.R_expert = sigma_points(sigma);               
                
                rm_ext = obj.reward_model.copy();
                rm_ext.add_demonstration(rollout);
                
                for i=1:batch.size
                    
                    ro = batch.get_rollout(i);
                    ro = rm_ext.add_reward(ro);
                    
                    batch.update_rollout(ro);
                end
                
                theta_star = obj.agent.get_probability_trajectories(batch);
                epd(sigma) = sum(theta_star.*log(theta_star./theta_tilda));
            end
            
            res = mean(epd);
        end
        
        function theta_per_sample = stack_theta(~, theta_ps)
            
            n_dof = length(theta_ps(:,1,1));
            n_bf = length(theta_ps(1,1,:));
            n_samples = length(theta_ps(1,:,1));
            theta_per_sample = zeros(n_samples, n_dof*n_bf);
            
            for i = 1:n_dof
                
                theta_per_sample(:,(i-1)*n_bf+1:i*n_bf) = squeeze(theta_ps(i,:,:));
            end        
        end
        
        function print_reward_kl(~, batch_tilda, batch_star)
        
            R_tilda = zeros(batch_tilda.size, 1);
            R_star = zeros(batch_star.size, 1);
            
            for i = 1:batch_tilda.size
                
                R_tilda(i,1) = batch_tilda.get_rollout(i).R;
                R_star(i,1) = batch_star.get_rollout(i).R;
            end
            
            figure
            hold on;
            scatter(R_tilda, zeros(batch_tilda.size, 1));
            scatter(R_star, zeros(batch_star.size, 1));
        end
        
        function print_kl(~, theta_tilda, theta_star)
            
            figure
            hold on;
            scatter(theta_tilda, zeros(length(theta_tilda), 1));
            scatter(theta_star, zeros(length(theta_star), 1));          
        end
        
        function print_r_in_rm(~, batch_tilda, batch_star)
            
            R_tilda = zeros(batch_tilda.size, 1);
            O_tilda = zeros(batch_tilda.size, 1);
            R_star = zeros(batch_star.size, 1);
            O_star = zeros(batch_star.size, 1);
            
            for i = 1:batch_tilda.size
                
                R_tilda(i,1) = batch_tilda.get_rollout(i).R;
                O_tilda(i,1) = batch_tilda.get_rollout(i).sum_out;
                
                R_star(i,1) = batch_star.get_rollout(i).R;
                O_star(i,1) = batch_star.get_rollout(i).sum_out;
            end
            
            scatter(O_tilda, R_tilda, '+', 'g');
            scatter(O_star, R_star, '+', 'p');  
        end
    end
end