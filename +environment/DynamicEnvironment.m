classdef DynamicEnvironment < environment.Environment
    % Environment with a dynamic reward function (also contains the expert).
    
    properties
        
        expert;
        agent;
        n_init_samples;
        
    end
    
    methods(Abstract)
        
        demonstrate_and_query_expert(obj, sample)
        update_reward(obj, batch_rollouts);
    end
    
    methods
        
        function obj = DynamicEnvironment(p, r, e, a)
            
            obj = obj@environment.Environment(p, r);
            obj.expert = e;
            obj.agent = a;
        end
        
        % Prepares the environment by demonstrating 4 rollouts and
        % initializing the reward function
        function prepare(obj)
            
            obj.index = 1;
            
            obj.n_init_samples = 8;
            
            % create the controls for the first batch of rollouts
            batch_trajectory = obj.agent.create_batch_trajectories(obj.n_init_samples);
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

                batch_rollouts.append_rollout(rollout);
            end
            
            for i = 1:batch_rollouts.size
                
                rollout = batch_rollouts.get_rollout(i);
                
                if obj.expert.manual == true
                    obj.expert.background(batch_rollouts);
                    rollout.R_expert = obj.expert.query_expert(rollout);
                else
                    rollout.R_expert = obj.expert.query_expert(rollout);
                end
                
                batch_rollouts.update_rollout(rollout);
            end
            
            obj.iteration = obj.iteration + 1;
            
            obj.reward_model.add_batch_demonstrations(batch_rollouts);
            obj.reward_model.init_hypers();
            obj.reward_model.minimize();
            obj.reward_model.print();
        end
      
        function [rollout] = demonstrate_rollout(obj, sample)
            
            disp('demonstrate rollout');
            rollout = obj.plant.run(sample);
        end
    end
end