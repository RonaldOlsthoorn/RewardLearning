classdef VPSingleGPRewardModel < reward.RewardModel
    
    properties
        
        gp;
        batch_demonstrations;
        n_segments;
        n; % number of time steps. rename.
        segment_start;
        segment_end;
    end
    
    methods
        
        function init_segments(obj)
            
            segment = floor(obj.n/obj.n_segments);
            obj.segment_end = segment*(1:(obj.n_segments-1));
            obj.segment_start = obj.segment_end+1;
            
            obj.segment_start = [1 obj.segment_start];
            obj.segment_end = [obj.segment_end obj.n];
        end
        
       function rollout = add_outcomes(obj, rollout)
            
            outcomes = obj.feature_block.compute_outcomes(rollout);           
            rollout.outcomes = outcomes;          
        end
        
        function rollout = add_reward(obj, rollout)
            
            input = zeros(1,obj.n_segments*length(rollout.outcomes(1,:)));
            
            for i = 1:length(rollout.outcomes(1,:))
                
                input(1,(i-1)*obj.n_segments+1:i*obj.n_segments) = ...
                    rollout.outcomes(:,i)';
            end
            reward = obj.gp.assess(input);
            rollout.R = reward;
        end
             
        function [m, s2] = assess(obj, rollout)
            
            input = zeros(1,obj.n_segments*length(rollout.outcomes(1,:)));
            
            for i = 1:length(rollout.outcomes(1,:))
                
                input(1,(i-1)*obj.n_segments+1:i*obj.n_segments) = ...
                    rollout.outcomes(:,i)';
            end
            
            [m, s2] = obj.gp.assess(input);            
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
            % TODO automatically compute dimensionality of outcomes.
            x_meas = zeros(obj.batch_demonstrations.size, obj.n_segments*2);
            y_meas = zeros(obj.batch_demonstrations.size, 1);
            
            for i = 1:obj.batch_demonstrations.size
                
                demo = obj.batch_demonstrations.get_rollout(i);
                
                for j = 1:length(demo.outcomes(1,:))
                    
                    x_meas(i, (j-1)*obj.n_segments+1:j*obj.n_segments) = ...
                        demo.outcomes(:,j)';
                end
                y_meas(i, :) = demo.R_expert;
            end
            
            obj.gp.x_measured = x_meas;
            obj.gp.y_measured = y_meas;
        end
        
        function minimize(obj)
            
            obj.gp.minimize();
        end
              
        % Make a copy of a handle object.
        function new = copy(this)
            % Instantiate new object of the same class.
            new = reward.VPSingleGPRewardModel();
            
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
        
        function print(~)
            
            %            obj.gp.print(obj.figID);
        end
        
    end
end