classdef VPAdvancedReference < handle
    % UNTITLED Summary of this class goes here
    % Detailed explanation goes here
    
    properties
        
        viapoints; % viapoints in 2d column vectors
        viapoints_t;
        
        plane_dim;
        plane_level;
        
        viaplane_t;
        plane;
        
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
        
        function obj = VPAdvancedReference(ref_par)
            
            obj.viapoints = ref_par.viapoint;
            obj.viapoints_t = ref_par.viapoint_t;
            
            obj.plane_dim = ref_par.plane_dim;
            obj.plane_level = ref_par.plane_level;
            
            obj.viaplane_t = ref_par.viaplane_t;
            obj.plane = refs.plane(ref_par);
                   
            obj.duration = ref_par.duration;
            obj.Ts = ref_par.Ts;      
            obj.t = 0:obj.Ts:(obj.duration-obj.Ts); 
        end     
        
        function res = to_struct(obj)
            
           res.type = 'VPAdvancedReference';

           res.viapoint = obj.viapoints;
           res.viapoint_t = obj.viapoints_t;
           
           res.viaplane_t = obj.viaplane_t;
           res.plane = obj.plane;
           
           res.plane_dim = obj.plane_dim;
           res.plane_level = obj.plane_level;
           
           res.duration = obj.duration;
           res.Ts = obj.Ts;
           res.t = obj.t;
            
        end
        
                
        function clear_overlay_handles(obj)
            
            obj.handles = [];           
                        
        end
        
        function print_reference_overlay(obj, figure_handle)
            
            figure(figure_handle);
            
            if ~isempty(obj.handles)
                for i = 1:length(obj.handles)
                    uistack(obj.handles(i), 'top');
                end
                return;
            end
            % assume that dimension of viapoint equals.
            d = length(obj.viapoints(:,1));
            
            for i = 1:(d)
                
                subplot(1,d+1,i);
                hold on;
                
                for j = 1:length(obj.viapoints(1,:))
                    
                    obj.handles(end+1) = scatter(obj.viapoints_t(j)*obj.Ts, obj.viapoints(i, j),...
                        40, 'Marker', '+', 'LineWidth', 2, ...
                        'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b');
                end
                
                obj.handles(end+1) = plot(obj.plane.t, ones(1,length(obj.plane.t))*obj.plane.tool(i), ...
                    'LineWidth', 2, 'Color', 'black');
            end
            
            subplot(1,d+1,d+1)
            hold on
            
            if d==2
                for j = 1:length(obj.viapoints(1,:)) 
                    obj.handles(end+1) = scatter(obj.viapoints(1, j), obj.viapoints(2, j),...
                        40, 'Marker', '+', 'LineWidth', 2, ...
                        'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b');
                end
            elseif d==3
                for j = 1:length(obj.viapoints(1,:)) 
                    obj.handles(end+1) = scatter3(obj.viapoints(1, j), obj.viapoints(2, j), obj.viapoints(3, j),...
                        40, 'Marker', '+', 'LineWidth', 2, ...
                        'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b');
                end
            end
        end
    end
end