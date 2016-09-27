classdef RewardModel < handle
    
    properties
    end
    
    methods(Abstract)
        
        reward = compute_reward(outcome);
    end
    
    methods
        
        function batch_reward = batch_compute_reward(batch_outcome)
       
           for i = 1:length(batch_outcome)
               
              batch_reward(i) = compute_reward(batch_outcome(i)); 
           end
            
        end
    end
end

