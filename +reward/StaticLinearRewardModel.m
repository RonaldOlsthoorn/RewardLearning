classdef StaticLinearRewardModel < reward.RewardModel
    % STATICLINEARREWARDMODEL: simple reward model based on the squared
    % tracking error of the trajectory.
    
    properties(Constant)
        
        weights = 1;
    end
    
    properties

    end
    
    methods
        
        function obj = StaticLinearRewardModel(reference)
            
            obj.feature_block = reward.SimpleOutcomeBlock(reference);           
        end
        
        % Compute reward. assumed squared error function is already in the
        % feature outcomes.
        function rollout = add_reward(obj, rollout)
            
            reward = obj.weights*rollout.outcomes;
            rollout.r = reward;
            rollout.r_cum = obj.cumulative_reward(reward); 
            rollout.R = sum(reward);
        end      
    end    
end