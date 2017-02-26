classdef RolloutBatch < handle
    % Container class, handling groups of rollouts. Used for imitating
    % set-like behaviour.
    
    properties
        
        batch;
        size = 0;
    end
    
    methods
        
        function append_rollout(obj, rollout)
            
            obj.batch = [obj.batch rollout];
            obj.size = obj.size+1;
        end
        
        function append_batch(obj, batch)
            
            obj.batch = [obj.batch batch.batch];
            obj.size = length(obj.batch);
        end
        
        % Returns rollout equal to r, if present in the set.
        function rollout = get_equal_rollout(obj, r)
                        
            rollout = [];
            
            for i= 1:obj.size
                if r.equals(obj.batch(i))
                    rollout = obj.batch(i);
                end
            end
        end
        
        % Overwrite rollout with new update r, if equal r is present.
        function update_rollout(obj, r)
            
            for i= 1:obj.size
                if r.equals(obj.batch(i))
                    obj.batch(i) = r;
                end
            end
        end
        
        % Returns rollout based on the order (note different index than
        % Rollout.index!).
        function rollout = get_rollout(obj, i)
            
            rollout = obj.batch(i);
        end
        
        % Returns true if rollout is present, otherwise false.
        function res = contains(obj, rollout)
            
            res = false;
            for i= 1:obj.size
                if rollout.equals(obj.batch(i))
                    res = true;
                end
            end
        end
        
        function res = is_empty(obj)
            
            if obj.size==0
                res = true;
            else 
                res = false;
            end
        end
        
        % Remove rollout object if present in the set.
        function delete(obj, rollout)
            
            for i= 1:obj.size
                if rollout.equals(obj.batch(i))
                    if i==1
                        obj.batch = obj.batch(2:end);
                    elseif i==obj.size
                        obj.batch = obj.batch(1:(end-1));
                    else
                        obj.batch = [obj.batch(1:(i-1)) obj.batch((i+1):end)];
                    end
                    obj.size = obj.size -1;
                    return;
                end
            end
        end
        
        % Make a copy of a handle object.
        function new = copy(this)
            % Instantiate new object of the same class.
            new = db.RolloutBatch();
 
            % Copy all non-hidden properties.
            p = properties(this);
            for i = 1:length(p)
                new.(p{i}) = this.(p{i});
            end
        end
        
        % Write as an array.
        function arr = to_str_array(obj)
            
           for i = 1:obj.size
               
               arr(i) = obj.batch(i).to_struct();
           end
        end
        
    end
    
    methods(Static)
        
        % returns a batch from an array of structs
        function obj = from_array(array)
            
            obj =  db.RolloutBatch();
            
            for i = 1:length(array)
                obj.append_rollout(rolllout.Rollout.from_array(array(i)));
            end
        end
    end
end
    
