classdef DB < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        table;
    end
    
    methods
        
        function append_row(obj, batch_rollouts)
            
            obj.table = [obj.table; batch_rollouts];
        end
    end
    
end

