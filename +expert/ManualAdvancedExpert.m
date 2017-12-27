classdef ManualAdvancedExpert < expert.Expert
    % Manual expert class for multi objective tasks. 
    
    properties
        
        figure_handle;
        
        handle_input_figure = 10;
        lock = false;
        
        n_segments;
        reference;
        hinput;
        
        manual = true;
        
        segment_start;
        segment_end;
        
        bg_color = (1-5/20)*ones(1,3);
    end
    
    methods
        
        % Constructor.
        % reference: object containing viapoints/viaplance.
        % n_seg: number of segments.
        function obj = ManualAdvancedExpert(reference, n_seg)
            
            obj.n_segments = n_seg;
            obj.reference = reference;
            
            obj.init_segments();
        end
        
        % Initializes start and end indices of segments.
        function init_segments(obj)
            
            n = length(obj.reference.t);
            segment = floor(n/obj.n_segments);
            obj.segment_end = segment*(1:(obj.n_segments-1));
            obj.segment_start = obj.segment_end+1;
            
            obj.segment_start = [1 obj.segment_start];
            obj.segment_end = [obj.segment_end n];
        end
        
        % Query rollout by showing the human expert the trajectory and
        % receiving a rating.
        % rollout: end effector trajectory to be rated.
        % rating: expert rating.
        function rating = query_expert(obj, rollout)
            
            obj.plot_rollout(rollout);
            obj.lock = true;
            
            while (obj.lock)
                
                pause(0.1);
            end
            
            rating = str2double(obj.hinput.String);
            close(obj.figure_handle);
        end
        
        % Returns the true reward, for comparisson. Not used due to
        % difference in rating scaling.
        function rating = true_reward(obj, rollout)
            
            res = zeros(1, length(obj.reference.viapoints(1,:)));
            for i = 1:length(obj.reference.viapoints(1,:))
                res(i)  = -sum((rollout.tool_positions(:, obj.reference.viapoints_t(i))'...
                    -obj.reference.viapoints(:,i)').^2, 2);
            end
            
            rating = sum(res);
        end
        
        % Callback for expert input event.
        function rating_callback(obj, ~, ~)
            
            [~, status] = str2num(obj.hinput.String);
            
            if (status)
                obj.lock = false;
            end
        end
        
        % Prepare background window. 
        % batch: set of rated trajectories, will be displayed in the
        % background.
        function background(obj, batch)
            
            obj.init_figure();
            obj.plot_background_batch(batch);
            obj.plot_reference();
            
            obj.plot_annotations(batch);
            
            obj.figure_handle.Visible = 'on';
        end
        
        % Initialize figure properties (sizes, axes, UI).
        function init_figure(obj)
            
            obj.figure_handle = figure('Visible','on',...
                'units','normalized','outerposition',[0 0 1 1]);
            
            uicontrol('Style', 'pushbutton', 'String', 'rate',...
                'Position',[1800, 600,100,25],...
                'Callback', {@(source, eventdata)rating_callback(obj, source, eventdata)});
            
            obj.hinput = uicontrol('Style', 'edit',...
                'Position',[1800,550,100,25]);
            
            subplot(1,3,1)
            xlabel('tool position t [s]');
            ylabel('tool position x [m]');
            
            subplot(1,3,2);
            xlabel('tool position t [s]');
            ylabel('tool position y [m]');
            
            subplot(1,3,3);
            xlabel('tool position x [m]');
            ylabel('tool position y [m]');
            axis('equal');
            
            obj.figure_handle.Visible = 'on';
        end
        
        % Plot the batch of background trajectories in the rating window.
        % batch: set of rated trajectories, will be displayed in the
        % background.
        function plot_background_batch(obj, batch)
            
            for i = 1:batch.size
                
                rollout = batch.get_rollout(i);
                
                subplot(1,3,1);
                hold on;
                plot(rollout.time, rollout.tool_positions(1,:),...
                    'b-', 'LineWidth', 1, 'Color', obj.bg_color);
                
                subplot(1,3,2);
                hold on;
                plot(rollout.time, rollout.tool_positions(2,:),...
                    'b-', 'LineWidth', 1, 'Color', obj.bg_color);
                
                subplot(1,3,3);
                hold on;
                plot(rollout.tool_positions(1,:), rollout.tool_positions(2,:),...
                    'b-', 'LineWidth', 1, 'Color', obj.bg_color);
            end
        end
        
        % Plot the reference viapoints/viaplane in the rating window.
        function plot_reference(obj)
            
            subplot(1,3,1);
            hold on;
            scatter(obj.reference.viapoints_t*obj.reference.Ts, obj.reference.viapoints(1),...
                40, 'Marker', '+', 'LineWidth', 2, ...
                'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b');
            plot(obj.reference.plane.t, obj.reference.plane.tool(1,:), ...
                'Color', 'cyan', 'LineWidth', 2);
            
            subplot(1,3,2);
            hold on;
            scatter(obj.reference.viapoints_t*obj.reference.Ts, obj.reference.viapoints(2),...
                40, 'Marker', '+', 'LineWidth', 2, ...
                'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b');
            plot(obj.reference.plane.t, obj.reference.plane.tool(2,:), ...
                'Color', 'cyan', 'LineWidth', 2);
            
            subplot(1,3,3);
            hold on;
            scatter(obj.reference.viapoints(1), obj.reference.viapoints(2),...
                40, 'Marker', '+', 'LineWidth', 2, ...
                'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b');
            plot(obj.reference.plane.tool(1,:), obj.reference.plane.tool(2,:), ...
                'Color', 'cyan', 'LineWidth', 2);
        end
        
        % Plot the to be rated rollout prominently in the rating window.
        % rollout: to be rated end effector trajectory.
        function plot_rollout(obj, rollout)
            
            subplot(1,3,1);
            hold on;
            plot(rollout.time, rollout.tool_positions(1,:), 'LineWidth', 2, 'Color', 'red');
            
            for i = 1:obj.n_segments
                
                t_position = (obj.segment_start(i)+(obj.segment_end(i)-obj.segment_start(i))/2)*obj.reference.Ts;
                t_segment = obj.reference.t(obj.segment_start(i):obj.segment_end(i));
                m_segment = ones(1, length(t_segment))*mean(rollout.tool_positions(1, obj.segment_start(i):obj.segment_end(i)));
                plot(t_segment, m_segment, 'Color', 'b');
                scatter(t_position, m_segment(1),...
                    40, 'Marker', 'd', 'LineWidth', 2, 'MarkerEdgeColor', 'k');
            end
            
            subplot(1,3,2);
            hold on;
            plot(rollout.time, rollout.tool_positions(2,:), 'LineWidth', 2, 'Color', 'red');
            
            for i = 1:obj.n_segments
                
                t_position = (obj.segment_start(i)+(obj.segment_end(i)-obj.segment_start(i))/2)*obj.reference.Ts;
                t_segment = obj.reference.t(obj.segment_start(i):obj.segment_end(i));
                m_segment = ones(1, length(t_segment))*mean(rollout.tool_positions(2, obj.segment_start(i):obj.segment_end(i)));
                plot(t_segment, m_segment, 'Color', 'b');
                scatter(t_position, m_segment(1),...
                    40, 'Marker', 'd', 'LineWidth', 2, 'MarkerEdgeColor', 'k');
            end
            
            subplot(1,3,3);
            hold on;
            
            plot(rollout.tool_positions(1,:), rollout.tool_positions(2,:), 'LineWidth', 2, 'Color', 'red');
            scatter(rollout.tool_positions(1, 300), rollout.tool_positions(2, 300), ...
                40, 'Marker', 'd', 'LineWidth', 2, 'MarkerEdgeColor', 'k');
        end
        
        % Plot annotations to the background trajectories, indicating the
        % previous given ratings.
        % batch: set of background rollouts.
        function plot_annotations(obj, batch)
            
            subplot(1,3,1);
            hold on;
            
            for i = 1:batch.size
                rollout = batch.get_rollout(i);
                
                if ~isempty(rollout.R_expert)
                    
                    text(rollout.time(500), rollout.tool_positions(1,500), ...
                        strcat('\leftarrow R=',num2str(rollout.R_expert)),...
                        'FontSize', 8, 'Color', obj.bg_color);
                end
            end
            
            subplot(1,3,2);
            hold on;
            
            for i = 1:batch.size
                rollout = batch.get_rollout(i);
                
                if ~isempty(rollout.R_expert)
                    
                    text(rollout.time(500), rollout.tool_positions(2,500), ...
                        strcat('\leftarrow R=',num2str(rollout.R_expert)),...
                        'FontSize', 8, 'Color', obj.bg_color);
                end
            end
            
            subplot(1,3,3);
            hold on;
            
            for i = 1:batch.size
                rollout = batch.get_rollout(i);
                
                if ~isempty(rollout.R_expert)
                    
                    text(rollout.tool_positions(1,500), rollout.tool_positions(2,500), ...
                        strcat('\leftarrow R=',num2str(rollout.R_expert)),...
                        'FontSize', 8, 'Color', obj.bg_color);
                end
            end
        end
    end
end

