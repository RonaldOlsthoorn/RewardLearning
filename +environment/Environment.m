classdef Environment < handle
    
    
    properties
        
        plant;
        reward_model;
        
    end
    
    methods
        
        function obj = Environment(p, r)
            
            obj.plant = p;
            obj.reward_model = r;
        end
        
        function rollout = run(obj, trajectory)
            
            rollout = obj.plant.run(trajectory);
            rollout = obj.reward_model.add_outcomes_and_reward(rollout);
        end
        
        function batch_rollouts = batch_run(obj, batch_trajectory)
            
            batch_rollouts = obj.plant.batch_run(batch_trajectory);
            
            for i=1:length(batch_rollouts)
                
                batch_rollouts(i) = obj.reward_model.add_outcomes_and_reward(batch_rollouts(i));
                
            end
            
        end
        
    end
    
end

