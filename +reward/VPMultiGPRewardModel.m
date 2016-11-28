classdef VPMultiGPRewardModel < reward.RewardModel
    
    
    properties
        
        batch_demonstrations;
        gps;
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
            
            for i=1:obj.n_segments
                rollout.sum_out(i) = sum(...
                    outcomes(obj.segment_start(i):obj.segment_end(i)));
            end
        end
        
        function rollout = add_reward(obj, rollout)
            
            R = zeros(obj.n_segments,1);
            
            for i = 1:obj.n_segments
                
                R(i) = obj.gps(i).assess(rollout.outcomes(1));
            end
            
            rollout.R = sum(R);
        end
        
        function [m, s2] = assess(obj, rollout, segment)
            
            [m, s2] = obj.gps(segment).assess(rollout.outcomes(1));            
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
            
            for i = 1:obj.n_segments
                x_meas = zeros(obj.batch_demonstrations.size, 1);
                y_meas = zeros(obj.batch_demonstrations.size, 1);
                
                for j = 1:obj.batch_demonstrations.size
                    demo = obj.batch_demonstrations.get_rollout(j);
                    
                    x_meas(j,1) = demo.sum_out(i);
                    y_meas(j,1) = demo.R_expert(i);
                end
                
                obj.gps(i).x_measured = x_meas;
                obj.gps(i).y_measured = y_meas;
            end
        end
        
        % Make a copy of a handle object.
        function new = copy(this)
            % Instantiate new object of the same class.
            new = reward.VPMultiGPRewardModel();
            
            % Copy all non-hidden properties.
            p = properties(this);
            for i = 1:length(p)
                if strcmp(p{i}, 'gps')
                               
                    for j = 1:this.n_segments
                        new_gps(j) = this.gps(j).copy();
                    end
                    new.(p{i}) = new_gps;
                elseif strcmp(p{i}, 'batch_demonstrations') 
                    new.(p{i}) = this.(p{i}).copy();
                elseif strcmp(p{i}, 'figID')
                    % Nothing, ow sweet nothing
                else
                    new.(p{i}) = this.(p{i});
                end
            end
        end
        
        function print(obj)
            
            figure(obj.figID);
            clf;              
            
            for i = 1:obj.n_segments
                
                minx = min(obj.gps(i).x_measured);
                maxx = max(obj.gps(i).x_measured);
                dx = (maxx-minx);
                
                x_grid = ((minx-dx):(dx/100):(maxx+dx))';
                
                [mPost, sPost] = obj.gps(i).assess(x_grid);
                
                subplot(2,2,i);
                hold on;
                grid on;
                
                patch([x_grid; flip(x_grid)], [mPost-2*sPost; flipud(mPost+2*sPost)], 1, 'FaceColor', [0.9,0.9,1], 'EdgeColor', 'none'); % This is the grey area in the plot.
                patch([x_grid; flip(x_grid)],[mPost-sPost; flipud(mPost+sPost)], 1, 'FaceColor', [0.8,0.8,1], 'EdgeColor', 'none'); % This is the grey area in the plot.
                set(gca, 'layer', 'top'); % We make sure that the grid lines and axes are above the grey area.
                plot(x_grid, mPost, 'b-', 'LineWidth', 1); % We plot the mean line.
                plot(obj.gps(i).x_measured, obj.gps(i).y_measured, 'ro'); % We plot the measurement points.
            end
        end
    end
end