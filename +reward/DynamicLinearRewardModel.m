classdef DynamicLinearRewardModel < reward.RewardModel
    % DYNAMICLINEARREWARDMODEL: simple reward model based on the squared
    % tracking error of the trajectory.
    
    properties
        
        gp;
    end
    
    methods
        
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
        
        % Make a copy of a handle object.
        function new = copy(this)
            % Instantiate new object of the same class.
            new = reward.DynamicLinearRewardModel();
            
            % Copy all non-hidden properties.
            p = properties(this);
            for i = 1:length(p)
                if strcmp(p{i}, 'gp')
                    new.(p{i}) = this.(p{i}).copy();
                else
                    new.(p{i}) = this.(p{i});
                end
            end
        end
    end
end

