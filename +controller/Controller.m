classdef Controller < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Abstract)
        
        control_input = control_law(r, r_d, x, v)
    end
    
end

