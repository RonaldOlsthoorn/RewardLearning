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
        
        function res = to_struct(obj)
            
            for i = 1:length(obj.table)
                res{i} = obj.table(i).to_str_array();
            end
        end
    end
    
    methods(Static)
        
        function obj = from_struct(struct)
            
            obj = db.DB;
                        
            for i = 1:length(struct)
                obj.append_row(db.RolloutBatch.from_array(struct{i}));
            end
        end
    end
end

