classdef UR5StaticVPRewardModel < reward.RewardModel
    % STATICVPREWARDMODEL: static reward model based on the squared
    % tracking error of the trajectory.
    
    properties(Constant)
        
    end
    
    properties
        
        ex;
    end
    
    methods
        
        
        function obj = UR5StaticVPRewardModel(reference)
            
            % obj.feature_block = reward.VPOutcomeBlock(reference);
            obj.ex = expert.UR5VPMultiSegmentExpert(0, reference, 4);
        end
        
        function rollout = add_outcomes(~, rollout)
            
        end
        
        % Uses expert to calculate reward. Add to rollout object.
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