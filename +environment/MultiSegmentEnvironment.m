classdef MultiSegmentEnvironment < environment.DynamicEnvironment
    % Dynamic environment containing a multi segment adaptive reward model
    % and acquisition algorithm.
    
    properties
        
        n_queries = 0;
        original_batch;
        tol;    
    end
    
    methods
        
        % Constructor.
        function obj = MultiSegmentEnvironment(plant, reward_model,...
                expert, agent)
            
            obj = obj@environment.DynamicEnvironment(plant, reward_model,...
                expert, agent);      
        end
        
        % Updates the reward if needed by demonstrating rollouts of the
        % batch if this is beneficial according to the epd acquisition
        % function.
        function update_reward(obj, batch_rollouts)
            
            obj.original_batch = batch_rollouts;
            unqueried_batch = batch_rollouts.copy();
            
            find_nominee = true;
            
            while true == find_nominee
                
                [max_rollout, max_epd, segment] = obj.find_max_acquisition(unqueried_batch);
                
                %disp(strcat('max epd: ', num2str(max_epd)));
                
                % rollouts are reused! therefore always check if rollout
                % already queried.
                if(~obj.reward_model.db_contains(max_rollout) && max_epd > obj.tol)
                    
                    if obj.expert.manual == true
                        obj.expert.background(obj.reward_model.db_demo(segment));
                    end
                    rollout = obj.demonstrate_and_query_expert(max_rollout, segment);
                    batch_rollouts.update_rollout(rollout);
                    
                    obj.reward_model.add_demonstration_segment(rollout, segment);
                    obj.reward_model.init_hypers();
                    obj.reward_model.minimize();
                    obj.reward_model.print();
                    unqueried_batch.delete(max_rollout);
                    
                    obj.n_queries = obj.n_queries + 1;
                    
                    unqueried_batch = obj.reward_model.add_reward_batch(unqueried_batch);
                    obj.original_batch = obj.reward_model.add_reward_batch(obj.original_batch);
                    
                    if unqueried_batch.is_empty()
                        find_nominee = false;
                    end
                else
                    find_nominee = false;
                end
            end
        end
        
        % Expected Policy Divergence (EPD) multi segment acquisition function.
        % rollout: trajectory for which the acquisition value will be
        % calculated.
        function [res, seg] = epd(obj, rollout)
            
            % epd for two sigma points. will take average later.
            epd = zeros(obj.reward_model.n_segments, 2);
            % policy according to unaltered reward model.
            theta_tilda = obj.agent.get_probability_trajectories(obj.original_batch);
            
            m = zeros(obj.reward_model.n_segments, 1);
            s2 = zeros(obj.reward_model.n_segments, 1);
            
            % calculate reward estimate for each segment.
            for segment = 1:obj.reward_model.n_segments
                
                [m(segment), s2(segment)] = ...
                    obj.reward_model.assess(rollout, segment);
            end
            
            for segment = 1:obj.reward_model.n_segments
                
                % construct sigma points for segment.
                sigma_points = m(segment)*[1 1];
                sigma_points = sigma_points +[s2(segment) -s2(segment)];
                
                for sigma = 1:2
                    
                    % extend reward model with sigma point.
                    batch = obj.original_batch.copy();
                    rollout.R_expert = m;
                    rollout.R_expert(segment) = sigma_points(:, sigma);
                    
                    rm_ext = obj.reward_model.copy();
                    rm_ext.add_demonstration(rollout);
                    
                    % calculate reward extended reward model for each
                    % trajectory in the batch.
                    for i=1:batch.size
                        
                        ro = batch.get_rollout(i);
                        ro = rm_ext.add_reward(ro);
                        
                        batch.update_rollout(ro);
                    end
                    
                    % calculate policy extended reward model.
                    theta_star = obj.agent.get_probability_trajectories(batch);
                    % calculate KL divergence.
                    epd(segment, sigma) = sum(theta_star.*log(theta_star./theta_tilda));
                end
            end
            
            % average epd over two sigma points. return segment with
            % highest epd.
            [res, seg] = max(mean(epd,2));         
            
            %mean(epd, 2)
        end
        
        % returns maximum epd segment.
        % batch_rollouts: set of rollouts from which we are to find the
        % maximum segment.
        % max_rollout: rollout containing the maximum epd segment.
        % max_epd: maximum epd value.
        % max_seg: segment containing the maximum (max_epd) epd value.
        function [max_rollout, max_epd, max_seg] = find_max_acquisition(obj, batch_rollouts)
            
            epd = zeros(1,batch_rollouts.size);
            seg = zeros(1,batch_rollouts.size);
            
            for i = 1:batch_rollouts.size
                [epd(i), seg(i)] = obj.epd(batch_rollouts.get_rollout(i));
                  
            end
            
            [max_epd, j] = max(epd);
            max_rollout = batch_rollouts.get_rollout(j);
            max_seg = seg(j);
        end
        
        % demonstrate query and obtain expert rating for specific segment.
        % sample: trajectory from which segment has to be queried.
        % segment: target trajectory segment.
        function rollout = demonstrate_and_query_expert(obj, sample, segment)
            
            rollout = obj.demonstrate_rollout(sample);
            
            rollout.R_expert = obj.expert.query_expert_segment(rollout, segment);
        end
        
        % print difference between reward models. Not used.
        function print_reward_kl(obj, rm_ext)
            
            figure(11);
            clf;              
            
            for i = 1:obj.reward_model.n_segments
                
                minx = min(obj.reward_model.gps(i).x_measured(:,1));
                miny = min(obj.reward_model.gps(i).x_measured(:,2));
                maxx = max(obj.reward_model.gps(i).x_measured(:,1));
                maxy = max(obj.reward_model.gps(i).x_measured(:,2));
                
                dx = (maxx-minx);
                dy = (maxy-miny);
                
                [x_grid, y_grid] = meshgrid(((minx-dx):(dx/10):(maxx+dx))',...
                                        ((miny-dy):(dy/10):(maxy+dy))');
                
                mPostOrig = zeros(size(x_grid));
                mPostNew = zeros(size(x_grid));
                
                for j = 1:length(x_grid)
                    
                    if obj.reward_model.gps(i).x_measured(1,:) == 2
                        tuples = [x_grid(:,j), y_grid(:,j)]; 
                    elseif obj.reward_model.gps(i).x_measured(1,:) == 4
                        tuples = [x_grid(:,j), y_grid(:,j), zeros(length(x_grid(:,j)), 2)]; 
                    end
                    
                    m_orig = obj.reward_model.gps(i).assess(tuples);
                    mPostOrig(:,j) = m_orig;
                    m_new = rm_ext.gps(i).assess(tuples);
                    mPostNew(:,j) = m_new;
                end
                
                subplot(2,2,i);
                hold on;
                grid on;
                
%                 patch([x_grid; flip(x_grid)], [mPost-2*sPost; flipud(mPost+2*sPost)], 1, 'FaceColor', [0.9,0.9,1], 'EdgeColor', 'none'); % This is the grey area in the plot.
%                 patch([x_grid; flip(x_grid)],[mPost-sPost; flipud(mPost+sPost)], 1, 'FaceColor', [0.8,0.8,1], 'EdgeColor', 'none'); % This is the grey area in the plot.
%                 set(gca, 'layer', 'top'); % We make sure that the grid lines and axes are above the grey area.
                
                surface(x_grid, y_grid, mPostOrig); % We plot the mean line.

                scatter3(rm_ext.gps(i).x_measured(:,1), rm_ext.gps(i).x_measured(:,2) , rm_ext.gps(i).y_measured, 'ro'); % We plot the measurement points.
                xlabel('mean x');
                ylabel('mean y');
                zlabel('Return');
                
                surface(x_grid, y_grid, mPostNew); % We plot the mean line.
            end

        end
                
    end
    
end