classdef VPReference < handle
    % UNTITLED Summary of this class goes here
    % Detailed explanation goes here
    
    properties
        
        viapoints; % viapoints in 2d column vectors
        viapoints_t;
        
        r_joints;
        r_joints_d;
        r_joints_dd;
        
        r_tool;
        r_tool_d;
        r_tool_dd;
        
        init_state;
        
        duration;
        Ts;
        t;      
        
        handles;
    end
    
    
    methods
        
        function obj = VPReference(ref_par)
            
            obj.viapoints = ref_par.viapoint;
            obj.viapoints_t = ref_par.viapoint_t;
            
            obj.duration = ref_par.duration;
            obj.Ts = ref_par.Ts;
            obj.t = 0:obj.Ts:(obj.duration-obj.Ts);
        end
        
        function res = to_struct(obj)
            
           res.type = 'VPReference';
            
           res.viapoint = obj.viapoints;
           res.viapoint_t = obj.viapoints_t;
           
           res.duration = obj.duration;
           res.Ts = obj.Ts;
           res.t = obj.t;
            
        end
        
        function clear_overlay_handles(obj)
            
            obj.handles = [];           
                        
        end
        
        function print_reference_overlay(obj, figure_handle)
            
            if ~isempty(obj.handles)
                for i = 1:length(obj.handles)
                    uistack(obj.handles(i), 'top');
                end
                return;
            end
            
            figure(figure_handle);
            % assume that dimension of viapoint equals.
            d = length(obj.viapoints(:,1));
            
            for i = 1:(d)
                
                subplot(1,d+1,i);
                hold on;
                
                for j = 1:length(obj.viapoints(1,:))
                    
                    obj.handles(end + 1) = scatter(obj.viapoints_t(j)*obj.Ts, obj.viapoints(i, j),...
                        40, 'Marker', '+', 'LineWidth', 2, ...
                        'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b');
                end
                
            end
            
            subplot(1,d+1,d+1)
            hold on
            
            if d==2
                for j = 1:length(obj.viapoints(1,:))
                    obj.handles(end + 1) = scatter(obj.viapoints(1, j), obj.viapoints(2, j),...
                        40, 'Marker', '+', 'LineWidth', 2, ...
                        'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b');
                end
            elseif d==3
                for j = 1:length(obj.viapoints(1,:))
                    obj.handles(end + 1) = scatter3(obj.viapoints(1, j), obj.viapoints(2, j), obj.viapoints(3, j),...
                        40, 'Marker', '+', 'LineWidth', 2, ...
                        'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b');
                end
            end
        end
        
    end
end