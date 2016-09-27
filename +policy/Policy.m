classdef Policy < handle
    
    properties
    end
    
    methods(Abstract)
        
        trajectory = get_trajectory(obj);
    end
    
end

