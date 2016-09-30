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
            %implement reward;
        end
        
        function batch_rollout = batch_run(obj, batch_trajectory)
            
            batch_rollout = obj.plant.batch_run(batch_trajectory);
            %implement reward;
            
        end
    end
    
end

