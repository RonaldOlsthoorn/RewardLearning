classdef DynamicLinearRewardModel < reward.RewardModel
    % DYNAMICLINEARREWARDMODEL: simple reward model based on the squared
    % tracking error of the trajectory.
    
    properties
        
        gp;
    end
    
    methods
        
        function obj = DynamicLinearRewardModel(reference, gp)
            
            obj.feature_block = reward.SimpleFeatureBlock(reference);
            obj.gp = gp;
        end
        
        function rollout = add_reward(obj, rollout)
            
            reward = obj.gp.interpolate(rollout.sum_out);
            rollout.R = reward;
       end 
        
        function add_demonstration(obj, demonstration)
            
            obj.gp.add_demonstration(demonstration);
        end
        
        function remove_demonstration(obj, demonstration)
            
            obj.gp.remove_demonstration(demonstration);
        end
        
        function add_batch_demonstrations(obj, batch_demonstrations)
            
            obj.gp.add_batch_demonstrations(batch_demonstrations)
        end
        
    end
    
end

