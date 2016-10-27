classdef DynamicEnvironment < environment.Environment
    
    properties
        
        expert;
        agent;
        
        original_batch;
        
        tol;
    end
    
    methods
        
        function obj = DynamicEnvironment(p, r, e, a, t)
            
            obj = obj@environment.Environment(p, r);
            obj.expert = e;
            obj.agent = a;
            obj.tol = t;
        end
        
        function prepare(obj)
            
            batch_trajectory = obj.agent.get_batch_trajectories();
            batch_rollouts = obj.plant.batch_run(batch_trajectory);
            
            for i = 1:batch_rollouts.size
                
                rollout = obj.reward_model.add_outcomes(batch_rollouts.get_rollout(i));
                rollout.R_expert = obj.expert.query_expert(rollout);
                batch_rollouts.update_rollout(rollout);
            end
            
            obj.reward_model.add_batch_demonstrations(batch_rollouts);
            obj.reward_model.gp.print();
        end
        
        function update_reward(obj, batch_rollouts)
            
            obj.update_reward_epd(batch_rollouts);
        end
        
        function update_reward_epd(obj, batch_rollouts)
            
            obj.original_batch = batch_rollouts;
            unqueried_batch = batch_rollouts.copy();
            
            find_nominee = true;   
            
            while true == find_nominee
                
                [max_rollout, max_epd] = obj.find_max_acquisition(unqueried_batch);
                
                if(~obj.reward_model.gp.batch_rollouts.contains(max_rollout) && max_epd > obj.tol)
                    rollout = obj.demonstrate_and_query_expert(max_rollout);
                    obj.reward_model.add_demonstration(rollout);
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
            
            [m, s2] = obj.reward_model.gp.interpolate_rollout(rollout);
            sigma_points = m(end) + [1 -1].*sqrt(s2(end));
            
            epd = zeros(1, 2);
            
            theta_tilda = obj.stack_theta(...
                obj.agent.get_PI2_update_per_sample(obj.original_batch));
            theta_tilda_mean = mean(theta_tilda,2);
            theta_tilda_cov = diag(var(theta_tilda'));
            
            for sigma = 1:length(sigma_points)
                
                batch = obj.original_batch;
                
                rollout.R_expert = sigma_points(sigma);
                
                obj.reward_model.add_demonstration(rollout);
                
                for i=1:batch.size
                    
                    r = obj.reward_model.add_outcomes_and_reward(...
                        batch.get_rollout(i));
                    
                    batch.update_rollout(r);
                end
                
                obj.reward_model.remove_demonstration(rollout);
                
                theta_star = obj.stack_theta(...
                    obj.agent.get_PI2_update_per_sample(batch));
                theta_star_mean = mean(theta_star,2);
                theta_star_cov = diag(var(theta_star'));
                
                theta_star_p = mvnpdf(theta_star', theta_star_mean', theta_star_cov);
                theta_tilda_p = mvnpdf(theta_tilda', theta_tilda_mean', theta_tilda_cov);
                
                epd(sigma) = sum(theta_star_p.*log(theta_star_p./theta_tilda_p));
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
    end
end