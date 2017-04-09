classdef Environment < handle    
    % Environment base class for reinforcement learning environments.
    % Environment designed to return in an episodic
    % fashion due to the nature of the application.
    
    properties
        
        plant;
        reward_model;     
        iteration = 0;
        index = 0;
    end
    
    methods(Abstract)
        
        update_reward(obj, batch_rollouts);
        prepare(obj);
    end
    
    methods
        
        % Constructor.
        % p: plant.
        % r: reward model.
        function obj = Environment(p, r)
            
            obj.plant = p;
            obj.reward_model = r;
        end
        
        % returns the result of running the system with the specified
        % control trajectory defined as input.
        function rollout = run(obj, trajectory)
            
            rollout = obj.plant.run(trajectory);
            rollout = obj.reward_model.add_outcomes_and_reward(rollout);
            
            rollout.index = obj.index;
            obj.index = obj.index + 1;
        end
        
        % returns the result of running the system with the specified
        % batch of control trajectories defined as input.
        function batch_rollouts = batch_run(obj, batch_trajectory)
            
            obj.index = 1;
            batch_trajectory = obj.plant.batch_run(batch_trajectory);
            batch_rollouts = db.RolloutBatch();
            
            for i=1:batch_trajectory.size
                                                
                r = obj.reward_model.add_outcomes_and_reward(...
                    batch_trajectory.get_rollout(i));   
                
                r.iteration = obj.iteration;
                r.index = obj.index;
                
                obj.index = obj.index + 1;
                
                batch_rollouts.append_rollout(r);
            end
            
            obj.iteration = obj.iteration + 1;
        end
    end
end