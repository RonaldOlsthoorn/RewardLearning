classdef Policy < handle
    
    properties
    end
    
    methods(Abstract)
        
        trajectory = create_trajectory(obj, eps);
    end
    
end

