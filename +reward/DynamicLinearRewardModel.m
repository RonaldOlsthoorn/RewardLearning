classdef DynamicLinearRewardModel < reward.RewardModel
    % DYNAMICLINEARREWARDMODEL: simple reward model based on the squared
    % tracking error of the trajectory.
    
    properties
        
        gp;
        batch_demonstrations;
    end
    
    methods
        
        function rollout = add_reward(obj, rollout)
            
            reward = obj.gp.assess(sum(rollout.outcomes));
            rollout.R = reward;
        end
        
        function add_demonstration(obj, demonstration)
            
            obj.batch_demonstrations.append_rollout(demonstration);
            obj.update_gps();
        end
        
        function remove_demonstration(obj, demonstration)
            
            obj.batch_demonstrations.delete(demonstration);
            obj.update_gps();
        end
        
        function add_batch_demonstrations(obj, batch_demonstrations)
            
            obj.batch_demonstrations.append_batch(batch_demonstrations)
            obj.update_gps();
        end
        
        function update_gps(obj)
            
            x_meas = zeros(obj.batch_demonstrations.size, 1);
            y_meas = zeros(obj.batch_demonstrations.size, 1);
            
            for i = 1:obj.batch_demonstrations.size
                
                x_meas(i, :) = sum(obj.batch_demonstrations.get_rollout(i).outcomes);
                y_meas(i, :) = obj.batch_demonstrations.get_rollout(i).R_expert;
            end
            
            obj.gp.x_measured = x_meas;
            obj.gp.y_measured = y_meas;
        end
        
        function print(obj)
            
            obj.gp.print(obj.figID);
        end
        
        % Make a copy of a handle object.
        function new = copy(this)
            % Instantiate new object of the same class.
            new = reward.DynamicLinearRewardModel();
            
            % Copy all non-hidden properties.
            p = properties(this);
            for i = 1:length(p)
                if strcmp(p{i}, 'gp') || strcmp(p{i}, 'batch_demonstrations')
                    new.(p{i}) = this.(p{i}).copy();
                elseif strcmp(p{i}, 'figID')
                    % Nothing, ow sweet nothing
                else
                    new.(p{i}) = this.(p{i});
                end
            end
        end
    end
end