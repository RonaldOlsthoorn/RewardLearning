classdef VPMultiGPRewardModel < reward.RewardModel
    
    properties
        
        db_demo;
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
        end
        
        function rollout = add_reward(obj, rollout)
            
            R = zeros(obj.n_segments,1);
            
            for i = 1:obj.n_segments
                
                R(i) = obj.gps(i).assess(rollout.outcomes(i,:));
            end
            
            rollout.R = sum(R);
        end
        
        function [m, s2] = assess(obj, rollout, segment)
            
            [m, s2] = obj.gps(segment).assess(rollout.outcomes(segment,:));            
        end
        
        function add_demonstration(obj, demonstration)
            
            for i = 1:obj.n_segments
                obj.db_demo(i).append_rollout(demonstration);
            end
            obj.update_gps();
        end 
        
        function add_demonstration_segment(obj, demonstration, seg)
            
            obj.db_demo(seg).append_rollout(demonstration);
            obj.update_gps();
        end
        
        function remove_demonstration(obj, demonstration)
            
            for s = 1:obj.n_segments
                obj.db_demo(s).delete(demonstration);
            end
            
            obj.update_gps();
        end
        
        function add_batch_demonstrations(obj, batch_demonstrations)
            
            for i = 1:obj.n_segments
                obj.db_demo(i).append_batch(batch_demonstrations)
            end
            
            obj.update_gps();
        end
        
        function res = db_contains(obj, rollout)
            
            res = false;
            
            for i = 1:obj.n_segments
                if obj.db_demo(i).contains(rollout)
                    res = true;
                    return
                end
            end
        end
        
        function update_gps(obj)
            
            for i = 1:obj.n_segments
                x_meas = zeros(obj.db_demo(i).size, 2);
                y_meas = zeros(obj.db_demo(i).size, 1);
                
                for j = 1:obj.db_demo(i).size
                    demo = obj.db_demo(i).get_rollout(j);
                    
                    x_meas(j,:) = demo.outcomes(i,:);
                    y_meas(j,1) = demo.R_expert(i);
                end
                
                obj.gps(i).x_measured = x_meas;
                obj.gps(i).y_measured = y_meas;
                %obj.gps(i).compute_features_measurements();
            end
        end
        
        function init_hypers(obj)
            
            d = length(obj.gps(1).x_measured(1,:));
            
            for i = 1:obj.n_segments
                
                lambda_x = std(obj.gps(i).x_measured);
                lambda_y = std(obj.gps(i).y_measured);
                
                if lambda_y == 0
                    lambda_y = mean(lambda_x);
                end
                
                sigma = lambda_y/10;
                
                obj.gps(i).hyp.cov(1:d, 1) = log(lambda_x);
                obj.gps(i).hyp.cov(d+1, 1) = log(lambda_y);
                obj.gps(i).hyp.lik = log(sigma);
            end
        end
        
        function minimize(obj)
            
           for i = 1:obj.n_segments
              obj.gps(i).minimize(); 
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
                elseif strcmp(p{i}, 'db_demo') 
                    db_cache = this.db_demo;
                    for j = 1:length(db_cache)
                        db_cp(j) = db_cache(j).copy();
                    end
                    new.(p{i}) = db_cp;
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
                
                minx = min(obj.gps(i).x_measured(:,1));
                miny = min(obj.gps(i).x_measured(:,2));
                maxx = max(obj.gps(i).x_measured(:,1));
                maxy = max(obj.gps(i).x_measured(:,2));
                
                dx = (maxx-minx);
                dy = (maxy-miny);
                
                [x_grid, y_grid] = meshgrid(((minx-dx):(dx/10):(maxx+dx))',...
                                        ((miny-dy):(dy/10):(maxy+dy))');
                
                mPost = zeros(size(x_grid));
                sPost = zeros(size(x_grid));
                
                for j = 1:length(x_grid)
                    
                    tuples = [x_grid(:,j), y_grid(:,j)];
                    [m, s] = obj.gps(i).assess(tuples);
                    mPost(:,j) = m;
                    sPost(:,j) = s;
                end
                
                subplot(2,2,i);
                hold on;
                grid on;
                
%                 patch([x_grid; flip(x_grid)], [mPost-2*sPost; flipud(mPost+2*sPost)], 1, 'FaceColor', [0.9,0.9,1], 'EdgeColor', 'none'); % This is the grey area in the plot.
%                 patch([x_grid; flip(x_grid)],[mPost-sPost; flipud(mPost+sPost)], 1, 'FaceColor', [0.8,0.8,1], 'EdgeColor', 'none'); % This is the grey area in the plot.
%                 set(gca, 'layer', 'top'); % We make sure that the grid lines and axes are above the grey area.
                
                surface(x_grid, y_grid, mPost); % We plot the mean line.
                surface(x_grid, y_grid, mPost-sPost);
                surface(x_grid, y_grid, mPost+sPost);
                
                scatter3(obj.gps(i).x_measured(:,1),obj.gps(i).x_measured(:,2) , obj.gps(i).y_measured, 'ro'); % We plot the measurement points.
                xlabel('mean x');
                ylabel('mean y');
                zlabel('Return');
            end
        end
    end
end