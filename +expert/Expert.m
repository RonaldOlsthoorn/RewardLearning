classdef Expert < handle
    % Base class for experts, both hard coded experts and manual experts.
    
    properties
    end
    
    methods(Abstract)
        
        rating = query_expert(obj, rollout)
    end
    
end