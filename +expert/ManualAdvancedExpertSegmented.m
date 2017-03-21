classdef ManualAdvancedExpertSegmented < expert.Expert
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        figure_handle;
        lock = false;
        
        n_segments;
        reference;
        hinput;
        
        segment_start;
        segment_end;
        
        manual = true;
        
        line_handles;
        text_handles;
        
        background_batch;
        
        bg_color = (1-5/20)*ones(1,3);
    end
    
    methods
        
        function obj = ManualAdvancedExpertSegmented(reference, n_seg)
            
            obj.n_segments = n_seg;
            obj.reference = reference;
            
            obj.init_segments();
        end
        
        function init_segments(obj)
            
            n = length(obj.reference.t);
            segment = floor(n/obj.n_segments);
            obj.segment_end = segment*(1:(obj.n_segments-1));
            obj.segment_start = obj.segment_end+1;
            
            obj.segment_start = [1 obj.segment_start];
            obj.segment_end = [obj.segment_end n];
        end
        
        function rating = true_reward(obj, rollout)
            
            rating = zeros(1, obj.n_segments);
            
            for i = 1:obj.n_segments
                
                for j = 1:length(obj.reference.viapoints(1,:))
                    
                    if obj.reference.viapoints_t(j)>= obj.segment_start(i) && ...
                            obj.reference.viapoints_t(j)<= obj.segment_end(i)
                        rating(i) = rating(i) - ...
                            sum((rollout.tool_positions(:, obj.reference.viapoints_t(j))'...
                            -obj.reference.viapoints(:,j)').^2, 2);
                    end
                end
            end
        end
        
        function rating_callback(obj, ~, ~)
            
            [~, status] = str2num(obj.hinput.String);
            
            if (status)
                obj.lock = false;
            end
        end
        
        function rating = query_expert(obj, rollout)
            
            figure(obj.figure_handle);
            
            rating = zeros(obj.n_segments, 1);
            obj.plot_rollout(rollout);
            
            for seg = 1:obj.n_segments
                
                obj.plot_overlay(rollout, seg);
                obj.plot_annotations(obj.background_batch, seg);
                obj.lock = true;
                
                while (obj.lock)
                    pause(0.1);
                end
                
                rating(seg) = str2double(obj.hinput.String);
                
                figure(obj.figure_handle);
                
                for i = 1:length(obj.line_handles)
                    
                    delete(obj.line_handles(i));
                end
                
                for i = 1:length(obj.text_handles)
                    
                    delete(obj.text_handles(i));
                end
            end
            
            close(obj.figure_handle);
        end
        
        function rating = query_expert_segment(obj, rollout, seg)
            
            figure(obj.figure_handle);
            
            obj.plot_rollout(rollout);
            obj.plot_overlay(rollout, seg);
            obj.plot_annotations(obj.background_batch, seg);
            obj.lock = true;
            
            while (obj.lock)
                pause(0.1);
            end
            
            for i = 1:length(obj.line_handles)
                
                delete(obj.line_handles(i));
            end
            
            rating(seg) = str2double(obj.hinput.String);
            
            close(obj.figure_handle);
        end
        
        function background(obj, batch)
            
            obj.init_figure();
            obj.plot_background_batch(batch);
            obj.plot_reference();
        end
        
        function init_figure(obj)
            
            obj.figure_handle = figure('Visible','on',...
                'units','normalized','outerposition',[0 0 1 1]);
            
            uicontrol('Style', 'pushbutton', 'String', 'rate',...
                'Position',[1800, 600,100,25],...
                'Callback', {@(source, eventdata)rating_callback(obj, source, eventdata)});
            
            obj.hinput = uicontrol('Style', 'edit',...
                'Position',[1800,550,100,25]);
            
            subplot(1,3,1);
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
        
        function plot_background_batch(obj, batch)
            
            obj.background_batch = batch;
            
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
        
        function plot_reference(obj)
            
            subplot(1,3,1);
            hold on;
            scatter(obj.reference.viapoints_t*obj.reference.Ts, obj.reference.viapoints(1), ...
                40, 'Marker', '+', 'LineWidth', 2, 'MarkerEdgeColor', 'k');
            plot(obj.reference.plane.t, obj.reference.plane.tool(1,:), ...
                'Color', 'cyan', 'LineWidth', 2);
            
            subplot(1,3,2);
            hold on;
            scatter(obj.reference.viapoints_t*obj.reference.Ts, obj.reference.viapoints(2), ...
                40, 'Marker', '+', 'LineWidth', 2, 'MarkerEdgeColor', 'k');
            plot(obj.reference.plane.t, obj.reference.plane.tool(2,:), ...
                'Color', 'cyan', 'LineWidth', 2);
            
            subplot(1,3,3);
            hold on;
            scatter(obj.reference.viapoints(1), obj.reference.viapoints(2), ...
                40, 'Marker', '+', 'LineWidth', 2, 'MarkerEdgeColor', 'k');
            plot(obj.reference.plane.tool(1,:), obj.reference.plane.tool(2,:), ...
                'Color', 'cyan', 'LineWidth', 2);
        end
        
        function plot_rollout(obj, rollout)
            
            figure(obj.figure_handle);
            
            subplot(1,3,1);
            hold on;
            plot(rollout.time, rollout.tool_positions(1,:), 'k');
            
            subplot(1,3,2);
            hold on;
            plot(rollout.time, rollout.tool_positions(2,:), 'k');
            
            subplot(1,3,3);
            hold on;
            plot(rollout.tool_positions(1,:), rollout.tool_positions(2,:), 'k');
            scatter(rollout.tool_positions(1, 300), rollout.tool_positions(2, 300), ...
                40, 'Marker', 'd', 'LineWidth', 2, 'MarkerEdgeColor', 'k');
            
        end
        
        function plot_overlay(obj, rollout, seg)
            
            figure(obj.figure_handle);
            
            t_position = (obj.segment_start(seg)+(obj.segment_end(seg)-obj.segment_start(seg))/2)*obj.reference.Ts;
            t_segment = obj.reference.t(obj.segment_start(seg):obj.segment_end(seg));
            
            m_segment = ones(1, length(t_segment))*mean(rollout.tool_positions(1, obj.segment_start(seg):obj.segment_end(seg)));
            
            subplot(1,3,1);
            hold on;
            obj.line_handles(1) = plot(rollout.time(obj.segment_start(seg):obj.segment_end(seg)), ...
                rollout.tool_positions(1, obj.segment_start(seg):obj.segment_end(seg)), ...
                'LineWidth', 2, 'Color', 'red');
            
            obj.line_handles(2) = plot(t_segment, m_segment, 'Color', 'b');
            obj.line_handles(3) = scatter(t_position, m_segment(1),...
                40, 'Marker', 'd', 'LineWidth', 2, 'MarkerEdgeColor', 'k');
            
            m_segment = ones(1, length(t_segment))*mean(rollout.tool_positions(2, obj.segment_start(seg):obj.segment_end(seg)));
            
            subplot(1,3,2);
            hold on;
            obj.line_handles(4) = plot(rollout.time(obj.segment_start(seg):obj.segment_end(seg)), ...
                rollout.tool_positions(2, obj.segment_start(seg):obj.segment_end(seg)), ...
                'LineWidth', 2, 'Color', 'red');
            
            obj.line_handles(5) = plot(t_segment, m_segment, 'Color', 'b');
            obj.line_handles(6) = scatter(t_position, m_segment(1),...
                40, 'Marker', 'd', 'LineWidth', 2, 'MarkerEdgeColor', 'k');
            
            m_segment_x = ones(1, length(t_segment))*mean(rollout.tool_positions(1, obj.segment_start(seg):obj.segment_end(seg)));
            m_segment_y = ones(1, length(t_segment))*mean(rollout.tool_positions(2, obj.segment_start(seg):obj.segment_end(seg)));
            
            subplot(1,3,3);
            hold on;
            obj.line_handles(7) = plot(rollout.tool_positions(1, obj.segment_start(seg):obj.segment_end(seg)), ...
                rollout.tool_positions(2, obj.segment_start(seg):obj.segment_end(seg)), ...
                'LineWidth', 2, 'Color', 'red');
            obj.line_handles(8) = scatter(m_segment_x(1), m_segment_y(1),...
                40, 'Marker', 'd', 'LineWidth', 2, 'MarkerEdgeColor', 'k');
            obj.line_handles(9) = plot(m_segment_x, rollout.tool_positions(2, obj.segment_start(seg):obj.segment_end(seg)), 'Color', 'b');
            obj.line_handles(10) = plot(rollout.tool_positions(1, obj.segment_start(seg):obj.segment_end(seg)), m_segment_y, 'Color', 'b');
            
            
        end
        
        function plot_annotations(obj, batch, seg)
              
            t_segment = floor(obj.segment_start(seg) + (obj.segment_end(seg) - obj.segment_start(seg))/2);
            
            j = 1;
            
            for i = 1:batch.size
                rollout = batch.get_rollout(i);
                
                if ~isempty(rollout.R_expert)
                    
                    subplot(1,3,1);
                    hold on;
                    obj.text_handles(j) = text(t_segment*obj.reference.Ts, rollout.tool_positions(1, t_segment), ...
                        strcat('\leftarrow R=',num2str(rollout.R_expert(seg))));
                    j = j + 1;
                    
                    subplot(1,3,2);
                    hold on;
                    obj.text_handles(j) = text(t_segment*obj.reference.Ts, rollout.tool_positions(2, t_segment), ...
                        strcat('\leftarrow R=',num2str(rollout.R_expert(seg))));
                    j = j + 1;
                    
                    subplot(1,3,3);
                    hold on;
                    obj.text_handles(j) = text(rollout.tool_positions(1, t_segment), rollout.tool_positions(2, t_segment), ...
                        strcat('\leftarrow R=',num2str(rollout.R_expert(seg))));
                    j = j + 1;
                end
                
            end
        end
    end
end