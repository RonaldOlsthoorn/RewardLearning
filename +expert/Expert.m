classdef Expert < handle
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Abstract)
        
        rating = query_expert(obj, rollout)
    end
    
end

