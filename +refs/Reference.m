classdef Reference < handle
    
    properties
        r_joints
        r_joints_d
        r_tool
        r_tool_d
        
        duration
        Ts
        t;
        
    end
    
    methods
        
        function obj = Reference(ref_par)
            
            obj.duration = ref_par.duration;
            obj.Ts = ref_par.Ts;      
            obj.t = 0:obj.Ts:(obj.duration-obj.Ts);
        end
    end   
end

