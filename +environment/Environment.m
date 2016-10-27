classdef Environment < handle    
    % Environment base class for reinforcement learning environments
    % (see Sutton & Barto). Environment designed to return in an episodic
    % fashion due to the nature of the application.
    
    properties
        
        plant;
        reward_model;     
    end
    
    methods
        
        function obj = Environment(p, r)
            
            obj.plant = p;
            obj.reward_model = r;
        end
        
        % returns the result of running the system with the specified
        % control trajectory defined as input.
        function rollout = run(obj, trajectory)
            
            rollout = obj.plant.run(trajectory);
            rollout = obj.reward_model.add_outcomes_and_reward(rollout);
        end
        
        % returns the result of running the system with the specified
        % batch of control trajectories defined as input.
        function batch_rollouts = batch_run(obj, batch_trajectory)
            
            batch_rollouts = obj.plant.batch_run(batch_trajectory);
            
            for i=1:batch_rollouts.size
                
                r = obj.reward_model.add_outcomes_and_reward(...
                    batch_rollouts.get_rollout(i));     
                
                batch_rollouts.update_rollout(r);
            end   
        end
    end
end

