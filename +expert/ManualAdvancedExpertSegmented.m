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
        
        
        function rating = query_expert(obj, rollout)
            
            figure(obj.figure_handle);
            
            rating = zeros(obj.n_segments, 1);
            obj.plot_rollout(rollout);
            
            hx = uicontrol('Style', 'text', 'Position',[600, 900, 100, 25]);
            hy = uicontrol('Style', 'text', 'Position',[1200, 900, 100, 25]);
            
            for seg = 1:obj.n_segments
                
                set(hx, 'String', ...
                    strcat('mean x in this segment: ', num2str(rollout.outcomes(seg,1))));
                
                set(hy, 'String', ...
                    strcat('mean y in this segment: ', num2str(rollout.outcomes(seg,2))));
                
                obj.plot_overlay(rollout, seg);
                obj.lock = true;
                
                while (obj.lock)
                    pause(0.1);
                end
                
                rating(seg) = str2double(obj.hinput.String);
                
                figure(obj.figure_handle);
                
                delete(obj.line_handles(1));
                delete(obj.line_handles(2));
                delete(obj.line_handles(3));
            end
            
            close(obj.figure_handle);
        end
        
        function rating = query_expert_segment(obj, rollout, seg)
            
            figure(obj.figure_handle);
            
            rating = zeros(obj.n_segments, 1);
            
            hx = uicontrol('Style', 'text', 'Position',[600, 900, 100, 25]);
            hy = uicontrol('Style', 'text', 'Position',[1200, 900, 100, 25]);
            
            set(hx, 'String', ...
                strcat('mean x in this segment: ', num2str(rollout.outcomes(seg,1))));
            
            set(hy, 'String', ...
                strcat('mean y in this segment: ', num2str(rollout.outcomes(seg,2))));
            
            obj.plot_rollout(rollout);
            obj.plot_overlay(rollout, seg);
            obj.lock = true;
            
            while (obj.lock)
                pause(0.1);
            end
            
            delete(obj.line_handles(1));
            delete(obj.line_handles(2));
            delete(obj.line_handles(3));
            
            rating(seg) = str2double(obj.hinput.String);
            
            close(obj.figure_handle);
        end
        
        
        function background(obj, batch)
            
            obj.figure_handle = figure('Visible','on',...
                'units','normalized','outerposition',[0 0 1 1]);
            
            uicontrol('Style', 'pushbutton', 'String', 'rate',...
                'Position',[1800, 600,100,25],...
                'Callback', {@(source, eventdata)rating_callback(obj, source, eventdata)});
            
            obj.hinput = uicontrol('Style', 'edit',...
                'Position',[1800,550,100,25]);
            
            obj.figure_handle.Visible = 'on';
            
            c = 1-5/20;
            co = [c, c, c];
            
            for i = 1:batch.size
                
                rollout = batch.get_rollout(i);
                
                subplot(1,3,1);
                hold on;
                plot(rollout.time, rollout.tool_positions(1,:),...
                    'b-', 'LineWidth', 1, 'Color', co);
                
                subplot(1,3,2);
                hold on;
                plot(rollout.time, rollout.tool_positions(2,:),...
                    'b-', 'LineWidth', 1, 'Color', co);
                
                subplot(1,3,3);
                hold on;
                plot(rollout.tool_positions(1,:), rollout.tool_positions(2,:),...
                    'b-', 'LineWidth', 1, 'Color', co);
            end
            
            subplot(1,3,1);
            hold on;
            scatter(obj.reference.viapoints_t*obj.reference.Ts, obj.reference.viapoints(1));
            xlabel('tool position t [s]');
            ylabel('tool position x [m]');
            
            subplot(1,3,2);
            hold on;
            scatter(obj.reference.viapoints_t*obj.reference.Ts, obj.reference.viapoints(2));
            xlabel('tool position t [s]');
            ylabel('tool position y [m]');
            
            subplot(1,3,3);
            hold on;
            scatter(obj.reference.viapoints(1), obj.reference.viapoints(2));
            xlabel('tool position x [m]');
            ylabel('tool position y [m]');
            
            obj.figure_handle.Visible = 'on';
        end
        
        function plot_rollout(obj, rollout)
            
            figure(obj.figure_handle);
            
            subplot(1,3,1);
            hold on;
            plot(rollout.time, rollout.tool_positions(1,:), 'k');
            xlabel('tool position t [s]');
            ylabel('tool position x [m]');
            subplot(1,3,2);
            hold on;
            plot(rollout.time, rollout.tool_positions(2,:), 'k');
            xlabel('tool position t [s]');
            ylabel('tool position y [m]');
            subplot(1,3,3);
            hold on;
            plot(rollout.tool_positions(1,:), rollout.tool_positions(2,:), 'k');
            xlabel('tool position x [m]');
            ylabel('tool position y [m]');
        end
        
        function plot_overlay(obj, rollout, seg)
            
            figure(obj.figure_handle);
            
            subplot(1,3,1);
            hold on;
            obj.line_handles(1) = plot(rollout.time(obj.segment_start(seg):obj.segment_end(seg)), ...
                rollout.tool_positions(1, obj.segment_start(seg):obj.segment_end(seg)), ...
                'LineWidth', 2);
            
            subplot(1,3,2);
            hold on;
            obj.line_handles(2) = plot(rollout.time(obj.segment_start(seg):obj.segment_end(seg)), ...
                rollout.tool_positions(2, obj.segment_start(seg):obj.segment_end(seg)), ...
                'LineWidth', 2);
            
            subplot(1,3,3);
            hold on;
            obj.line_handles(3) = plot(rollout.tool_positions(1, obj.segment_start(seg):obj.segment_end(seg)), ...
                rollout.tool_positions(2, obj.segment_start(seg):obj.segment_end(seg)), ...
                'LineWidth', 2);
        end
        
        function rating_callback(obj, ~, ~)
            
            [~, status] = str2num(obj.hinput.String);
            
            if (status)
                obj.lock = false;
            end
            
            
        end
        
    end
    
end