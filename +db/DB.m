classdef DB < handle
    % Container of all rollouts in the run. Permanent storage not
    % implemented.
    
    properties
        
        table;
    end
    
    methods
        
        % Append batch of rollouts to the database.
        % batch_rollouts: batch to be added to the database.
        function append_row(obj, batch_rollouts)
            
            obj.table = [obj.table; batch_rollouts];
        end
        
        % Convert complete database to struct
        % res: array containing database
        function res = to_struct(obj)
            
            for i = 1:length(obj.table)
                res{i} = obj.table(i).to_str_array();
            end
        end
    end
    
    methods(Static)
        
        % Create new DB object from struct.
        % struct: struct containing all batches.
        function obj = from_struct(struct)
            
            obj = db.DB;
                        
            for i = 1:length(struct)
                obj.append_row(db.RolloutBatch.from_array(struct{i}));
            end
        end
    end
end

