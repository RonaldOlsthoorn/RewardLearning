classdef Expert < handle
    % Base class for experts
    
    properties
    end
    
    methods(Abstract)
        
        rating = query_expert(obj, rollout)
    end
    
end