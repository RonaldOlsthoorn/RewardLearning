classdef SingleSegmentEnvironment < environment.DynamicEnvironment
    %
    
    properties
        
        n_queries = 0;
        
        original_batch;
        tol;
    end
    
    methods
        
        % Constructor.
        function obj = SingleSegmentEnvironment(plant, reward_model,...
                expert, agent)
            
            obj = obj@environment.DynamicEnvironment(plant, reward_model,...
                expert, agent);
        end
        
        % Updates the reward if needed by demonstrating rollouts of the
        % batch if this is beneficial according to the epd acquisition
        % function.
        function update_reward(obj, batch_rollouts)
            
            obj.original_batch = batch_rollouts;
            unqueried_batch = batch_rollouts.copy();
            
            find_nominee = true;
            
            while true == find_nominee
                
                [max_rollout, max_epd] = obj.find_max_acquisition(unqueried_batch);
                
                %disp(strcat('max epd: ', num2str(max_epd)));
                
                % rollouts are reused! therefore always check if rollout
                % already queried.
                if(~obj.reward_model.batch_demonstrations.contains(max_rollout) && max_epd > obj.tol)
                    
                    if obj.expert.manual == true
                        
                        obj.expert.background(obj.reward_model.batch_demonstrations);
                    end
                    
                    rollout = obj.demonstrate_and_query_expert(max_rollout);
                    batch_rollouts.update_rollout(rollout);
                    obj.reward_model.add_demonstration(rollout);
                    
                    obj.reward_model.init_hypers();
                    obj.reward_model.minimize();
                    
                    
                    unqueried_batch.delete(max_rollout);
                    
                    unqueried_batch = obj.reward_model.add_reward_batch(unqueried_batch);
                    obj.original_batch = obj.reward_model.add_reward_batch(obj.original_batch);
                    
                    obj.n_queries = obj.n_queries + 1;
                    
                    obj.reward_model.print();
                    
                    if unqueried_batch.is_empty()
                        find_nominee = false;
                    end
                else
                    find_nominee = false;
                end
            end
        end
        
        
        % Expected Policy Divergence (EPD) acquisition function.
        % rollout: trajectory for which the acquisition value will be
        % calculated.        
        function res = epd(obj, rollout)
            
            % calculate expected expert return and variance.
            [m, s2] = obj.reward_model.assess(rollout);
            % construct sigma points.
            sigma_points = m(end) + [1 -1]*s2(end);
              
            epd = zeros(1, 2);
            
            % policy according to unaltered reward model.             
            theta_tilda = obj.agent.get_probability_trajectories(obj.original_batch);
            
            for sigma = 1:length(sigma_points)
                
                % extend reward model with sigma point.
                batch = obj.original_batch.copy();
                rollout.R_expert = sigma_points(sigma);
                
                rm_ext = obj.reward_model.copy();
                rm_ext.add_demonstration(rollout);
                
                % calculate reward extended reward model for each
                % trajectory in the batch.
                for i=1:batch.size
                    
                    ro = batch.get_rollout(i);
                    ro = rm_ext.add_reward(ro);
                    
                    batch.update_rollout(ro);
                end
                % calculate policy extended reward model.
                theta_star = obj.agent.get_probability_trajectories(batch);
                 % calculate KL divergence.
                epd(sigma) = sum(theta_star.*log(theta_star./theta_tilda));
            end
            % average epd over two sigma points.
            res = mean(epd);
        end
        
        % returns maximum epd trajectory.
        % batch_rollouts: set of rollouts from which we are to find the
        % maximum epd rollout.
        % max_rollout: rollout containing the maximum epd value.
        % max_epd: maximum epd value.
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
        
        % demonstrate query and obtain expert rating for specific rollout.
        % sample: trajectory to be queried.
        function rollout = demonstrate_and_query_expert(obj, sample)
            
            rollout = obj.demonstrate_rollout(sample);
            rollout.R_expert = obj.expert.query_expert(rollout);
        end
        
        % print difference between reward models. Not used.
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
        
        % print difference between policies. Not used.
        function print_kl(~, theta_tilda, theta_star)
            
            figure
            hold on;
            scatter(theta_tilda, zeros(length(theta_tilda), 1));
            scatter(theta_star, zeros(length(theta_star), 1));
        end
        
        % print difference between reward models. Not used.
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

