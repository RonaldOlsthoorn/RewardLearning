classdef VPReference < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        vp;
        vp_t;
        
        r_joints;
        r_tool;
        
        init_state;
        
        duration;
        Ts;
        t;      
    end
    
    methods
        
        function obj = VPReference(ref_par)
            
            obj.vp = ref_par.viapoint;
            obj.vp_t = ref_par.viapoint_t;
            
            obj.duration = ref_par.duration;
            obj.Ts = ref_par.Ts;      
            obj.t = 0:obj.Ts:(obj.duration-obj.Ts);
            
            
        end
        
    end
    
end

