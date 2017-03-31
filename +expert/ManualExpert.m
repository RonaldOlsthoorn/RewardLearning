classdef ManualExpert < expert.Expert
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
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
        
        function obj = ManualExpert(reference, n_seg)
            
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
            
            res = zeros(1, length(obj.reference.viapoints(1,:)));
            for i = 1:length(obj.reference.viapoints(1,:))
                res(i)  = -sum((rollout.tool_positions(:, obj.reference.viapoints_t(i))'...
                    -obj.reference.viapoints(:,i)').^2, 2);
            end
            
            rating = sum(res);
        end
        
        function rating_callback(obj, ~, ~)
            
            [~, status] = str2num(obj.hinput.String);
            
            if (status)
                obj.lock = false;
            end
        end
        
        function rating = query_expert(obj, rollout)
            
            obj.plot_rollout(rollout);
            obj.lock = true;
            
            while (obj.lock)
                
                pause(0.1);
            end
            
            rating = str2double(obj.hinput.String);
            close(obj.figure_handle);
        end
        
        function background(obj, batch)
            
            obj.init_figure();
            obj.plot_background_batch(batch);
            obj.plot_reference();
            
            obj.plot_annotations(batch);
            
            obj.figure_handle.Visible = 'on';
        end
        
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
        
        function plot_reference(obj)
            
            subplot(1,3,1);
            hold on;
            scatter(obj.reference.viapoints_t*obj.reference.Ts, obj.reference.viapoints(1),...
                40, 'Marker', '+', 'LineWidth', 2, ...
                'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b');
            
            subplot(1,3,2);
            hold on;
            scatter(obj.reference.viapoints_t*obj.reference.Ts, obj.reference.viapoints(2),...
                40, 'Marker', '+', 'LineWidth', 2, ...
                'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b');
            
            subplot(1,3,3);
            hold on;
            scatter(obj.reference.viapoints(1), obj.reference.viapoints(2),...
                40, 'Marker', '+', 'LineWidth', 2, ...
                'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b');
        end
        
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
        
        function plot_annotations(obj, batch)
            
            subplot(1,3,1);
            hold on;
            
            for i = 1:batch.size
                rollout = batch.get_rollout(i);
                
                if ~isempty(rollout.R_expert)
                    
                    text(rollout.time(300), rollout.tool_positions(1,500), ...
                        strcat('\leftarrow R=',num2str(rollout.R_expert)),...
                        'FontSize', 8, 'Color', obj.bg_color);
                end
            end
            
            subplot(1,3,2);
            hold on;
            
            for i = 1:batch.size
                rollout = batch.get_rollout(i);
                
                if ~isempty(rollout.R_expert)
                    
                    text(rollout.time(300), rollout.tool_positions(2,500), ...
                        strcat('\leftarrow R=',num2str(rollout.R_expert)),...
                        'FontSize', 8, 'Color', obj.bg_color);
                end
            end
            
            subplot(1,3,3);
            hold on;
            
            for i = 1:batch.size
                rollout = batch.get_rollout(i);
                
                if ~isempty(rollout.R_expert)
                    
                    text(rollout.tool_positions(1,300), rollout.tool_positions(2,300), ...
                        strcat('\leftarrow R=',num2str(rollout.R_expert)),...
                        'FontSize', 8, 'Color', obj.bg_color);
                end
            end
        end
    end
end