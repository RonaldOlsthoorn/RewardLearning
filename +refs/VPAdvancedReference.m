classdef VPAdvancedReference < handle
    % UNTITLED Summary of this class goes here
    % Detailed explanation goes here
    
    properties
        
        viapoints; % viapoints in 2d column vectors
        viapoints_t;
        
        viaplane;
        viaplane_t;
        
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
    end
    
    methods
        
        function obj = VPAdvancedReference(ref_par)
            
            obj.viapoints = ref_par.viapoint;
            obj.viapoints_t = ref_par.viapoint_t;
            
            obj.viaplane = ref_par.viaplane;
            obj.viaplane_t = ref_par.viaplane_t;
            
            obj.duration = ref_par.duration;
            obj.Ts = ref_par.Ts;      
            obj.t = 0:obj.Ts:(obj.duration-obj.Ts);            
        end     
    end
end

