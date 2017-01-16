classdef MultiSegmentEnvironment < environment.DynamicEnvironment
    %
    
    properties
        
        n_queries = 0;
        original_batch;
        tol;
        
    end
    
    methods
        
        function obj = MultiSegmentEnvironment(plant, reward_model,...
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
                
                [max_rollout, max_epd, segment] = obj.find_max_acquisition(unqueried_batch);
                
                %disp(strcat('max epd: ', num2str(max_epd)));
                
                % rollouts are reused! therefore always check if rollout
                % already queried.
                if(~obj.reward_model.db_contains(max_rollout) && max_epd > obj.tol)
                    
                    rollout = obj.demonstrate_and_query_expert(max_rollout, segment);
                    batch_rollouts.update_rollout(rollout);
                    obj.reward_model.add_demonstration_segment(rollout, segment);
                    obj.reward_model.minimize();
                    obj.reward_model.print();
                    unqueried_batch.delete(max_rollout);
                    
                    obj.n_queries = obj.n_queries + 1;
                    
                    unqueried_batch = obj.reward_model.add_reward_batch(unqueried_batch);
                    obj.original_batch = obj.reward_model.add_reward_batch(obj.original_batch);
                    
                    if unqueried_batch.is_empty()
                        find_nominee = false;
                    end
                else
                    find_nominee = false;
                end
            end
        end
        
        
        function [res, seg] = epd(obj, rollout)
            
            epd = zeros(obj.reward_model.n_segments, 2);
            theta_tilda = obj.agent.get_probability_trajectories(obj.original_batch);
            
            m = zeros(obj.reward_model.n_segments, 1);
            s2 = zeros(obj.reward_model.n_segments, 1);
            
            for segment = 1:obj.reward_model.n_segments
                
                [m(segment), s2(segment)] = ...
                    obj.reward_model.assess(rollout, segment);
            end
            
            for segment = 1:obj.reward_model.n_segments
                
                sigma_points = m(segment)*[1 1];
                sigma_points = sigma_points +[s2(segment) -s2(segment)];
                
                for sigma = 1:2
                    
                    batch = obj.original_batch.copy();
                    rollout.R_expert = m;
                    rollout.R_expert(segment) = sigma_points(:, sigma);
                    
                    rm_ext = obj.reward_model.copy();
                    rm_ext.add_demonstration(rollout);
                    
                    for i=1:batch.size
                        
                        ro = batch.get_rollout(i);
                        ro = rm_ext.add_reward(ro);
                        
                        batch.update_rollout(ro);
                    end
                    
                    theta_star = obj.agent.get_probability_trajectories(batch);
                    epd(segment, sigma) = sum(theta_star.*log(theta_star./theta_tilda));
                end
            end
            
            [res, seg] = max(mean(epd,2));         
            
            mean(epd, 2)
        end
        
        function [max_rollout, max_epd, max_seg] = find_max_acquisition(obj, batch_rollouts)
            
            epd = zeros(1,batch_rollouts.size);
            seg = zeros(1,batch_rollouts.size);
            
            for i = 1:batch_rollouts.size
                [epd(i), seg(i)] = obj.epd(batch_rollouts.get_rollout(i));
                  
            end
            
            [max_epd, j] = max(epd);
            max_rollout = batch_rollouts.get_rollout(j);
            max_seg = seg(j);
        end
        
        function rollout = demonstrate_and_query_expert(obj, sample, segment)
            
            rollout = obj.demonstrate_rollout(sample);
            rollout.R_expert = obj.expert.query_expert_segment(rollout, segment);
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