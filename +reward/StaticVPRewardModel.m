classdef StaticVPRewardModel < reward.RewardModel
    % STATICVPREWARDMODEL: simple reward model based on the squared
    % tracking error of the trajectory.
    
    properties(Constant)
        
    end
    
    properties

    end
    
    methods
        
        function obj = StaticVPRewardModel(reference)
            
            obj.feature_block = reward.VPOutcomeBlock(reference);           
        end
        
        function rollout = add_reward(obj, rollout)
            
            reward = rollout.outcomes;
            rollout.r = reward;
            rollout.r_cum = obj.cumulative_reward(reward); 
            rollout.R = sum(reward);
        end     
        
        function print(~)
            
        end
    end    
end