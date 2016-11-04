classdef DB < handle
    % Container of all rollouts in the run. Permanent storage not
    % implemented.
    
    properties
        
        table;
    end
    
    methods
        
        function append_row(obj, batch_rollouts)
            
            obj.table = [obj.table; batch_rollouts];
        end
    end
end

