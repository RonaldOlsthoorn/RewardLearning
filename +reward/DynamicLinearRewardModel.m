classdef DynamicLinearRewardModel < reward.RewardModel
    % DYNAMICLINEARREWARDMODEL: Simple reward model based on the squared
    % tracking error of the trajectory.
    
    properties
        
        gp;
        batch_demonstrations;
    end
    
    methods
        
        % Add reward to rollout.
        function rollout = add_reward(obj, rollout)
            
            % assume the outcomes contain squared error.
            reward = obj.gp.assess(sum(rollout.outcomes));
            rollout.R = reward;
        end
        
        % Add rated demonstration to reward model.
        function add_demonstration(obj, demonstration)
            
            obj.batch_demonstrations.append_rollout(demonstration);
            obj.update_gps();
        end
        
        % Remove rated demonstration to reward model.
        function remove_demonstration(obj, demonstration)
            
            obj.batch_demonstrations.delete(demonstration);
            obj.update_gps();
        end
        
        % Add batch of demonstrations to reward model (used i.e.
        % initialization).
        function add_batch_demonstrations(obj, batch_demonstrations)
            
            obj.batch_demonstrations.append_batch(batch_demonstrations)
            obj.update_gps();
        end
        
        % Synchronize training points gp with demonstration objects in
        % batch_demonstrations.
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
        
        % Print gp mean and variance if possible (number of inputs must not
        % exceed 2).
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