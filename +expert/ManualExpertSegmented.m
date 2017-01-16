classdef ManualExpertSegmented < expert.Expert
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        handle_input_figure = 10;
        lock = false;
        
        n_segments;
        reference;
        hinput;
        
        segment_start;
        segment_end;
    end
    
    methods
        
        function obj = ManualExpertSegmented(reference, n_seg)
            
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
        
        function rating = query_expert(obj, rollout)
            
            rating = zeros(obj.n_segments, 1);
            
            f = figure('Visible','on',...
                'units','normalized','outerposition',[0 0 1 1]);
            
            uicontrol('Style', 'pushbutton', 'String', 'rate',...
                'Position',[1800,500,100,25],...
                'Callback', {@(source, eventdata)rating_callback(obj, source, eventdata)});
            
            obj.hinput = uicontrol('Style', 'edit',...
                'Position',[1800,450,100,25]);
            
            f.Visible = 'on';
            
            obj.plot_rollout(rollout);
            
            for seg = 1:obj.n_segments
                obj.plot_overlay(rollout, seg);
                
                obj.lock = true;
                
                while (obj.lock)
                    
                    pause(0.1);
                end
                
                rating(seg) = str2double(obj.hinput.String);   
                
            end
            
            close(f);
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
        
        function plot_rollout(obj, rollout)
            
            subplot(1,3,1);
            hold on;
            plot(rollout.time, rollout.tool_positions(1,:));
            scatter(obj.reference.viapoints_t*obj.reference.Ts, obj.reference.viapoints(1));
            xlabel('tool position t [s]');
            ylabel('tool position x [m]');
            subplot(1,3,2);
            hold on;
            plot(rollout.time, rollout.tool_positions(2,:));
            scatter(obj.reference.viapoints_t*obj.reference.Ts, obj.reference.viapoints(2));
            xlabel('tool position t [s]');
            ylabel('tool position y [m]');
            subplot(1,3,3);
            hold on;
            plot(rollout.tool_positions(1,:), rollout.tool_positions(2,:));
            scatter(obj.reference.viapoints(1), obj.reference.viapoints(2));
            xlabel('tool position x [m]');
            ylabel('tool position y [m]');
        end
        
        function plot_overlay(obj, rollout, seg)
            
            subplot(1,3,1);
            hold on;
            plot(rollout.time(obj.segment_start(seg):obj.segment_end(seg)), ...
                rollout.tool_positions(1, obj.segment_start(seg):obj.segment_end(seg)), ...
                'LineWidth', 2);
            subplot(1,3,2);
            hold on;
            plot(rollout.time(obj.segment_start(seg):obj.segment_end(seg)), ...
                rollout.tool_positions(2, obj.segment_start(seg):obj.segment_end(seg)), ...
                'LineWidth', 2);
            subplot(1,3,3);
            hold on;
            plot(rollout.tool_positions(1, obj.segment_start(seg):obj.segment_end(seg)), ...
                rollout.tool_positions(2, obj.segment_start(seg):obj.segment_end(seg)), ...
                'LineWidth', 2);
        end
        
    end
    
end