classdef ManualExpert < expert.Expert
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        handle_input_figure = 10;
        lock = false;
        
        n_segments;
        reference;
        hinput;
        
        manual = true;
    end
    
    methods
        
        function obj = ManualExpert(reference, n_seg)
            
            obj.n_segments = n_seg;
            obj.reference = reference;
        end
        
        function rating = query_expert(obj, rollout)
            
           f = figure('Visible','on',...
               'units','normalized','outerposition',[0 0 1 1]);
           
           uicontrol('Style', 'pushbutton', 'String', 'rate',...
               'Position',[1800,500,100,25],...
               'Callback', {@(source, eventdata)rating_callback(obj, source, eventdata)});
           
           obj.hinput = uicontrol('Style', 'edit',...
               'Position',[1800,450,100,25]);
           
           f.Visible = 'on';
           
           obj.plot_rollout(rollout);
           
           obj.lock = true;
           
           while (obj.lock)
               
               pause(0.1);
           end
           
           rating = str2double(obj.hinput.String);
           
           close(f);
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
    end
    
end

