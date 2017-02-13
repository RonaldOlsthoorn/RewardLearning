classdef SingleSegmentEnvironment < environment.DynamicEnvironment
    %
    
    properties
        
        n_queries = 0;
        
        original_batch;
        tol;
    end
    
    methods
        
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
        
        
        function res = epd(obj, rollout)
            
            [m, s2] = obj.reward_model.assess(rollout);
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
        
        function rollout = demonstrate_and_query_expert(obj, sample)
            
            rollout = obj.demonstrate_rollout(sample);
            rollout.R_expert = obj.expert.query_expert(rollout);
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

