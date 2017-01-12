classdef Policy < handle
% Base class for policies.

    properties
    end
    
    methods(Abstract)
        
        trajectory = create_trajectory(obj, eps);
        trajectory = create_noiseless_trajectory(obj)
    end
    
end

