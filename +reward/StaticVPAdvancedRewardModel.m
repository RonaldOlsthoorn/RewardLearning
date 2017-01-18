classdef StaticVPAdvancedRewardModel < reward.RewardModel
    % STATICVPREWARDMODEL: simple reward model based on the squared
    % tracking error of the trajectory.
    
    properties(Constant)
        
    end
    
    properties
        
        ex;
    end
    
    methods
        
        function obj = StaticVPAdvancedRewardModel(reference)
            
            % obj.feature_block = reward.VPOutcomeBlock(reference);
            obj.ex = expert.VPAdvancedMultiSegmentExpert(0, reference, 4);
        end
        
        function rollout = add_outcomes(~, rollout)
            
        end
        
        function rollout = add_reward(obj, rollout)
            
            reward = obj.ex.query_expert(rollout);
            rollout.r = reward;
            rollout.r_cum = obj.cumulative_reward(reward); 
            rollout.R = sum(reward);
        end     
        
        function print(~)
            
        end
    end    
end