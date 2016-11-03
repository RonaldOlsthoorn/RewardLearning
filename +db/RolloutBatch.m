classdef RolloutBatch < handle
    
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
        
        function rollout = get_equal_rollout(obj, r)
            
            for i= 1:obj.size
                if r.equals(obj.batch(i))
                    rollout = obj.batch(i);
                end
            end
        end
        
        function update_rollout(obj, r)
            
            for i= 1:obj.size
                if r.equals(obj.batch(i))
                    obj.batch(i) = r;
                end
            end
        end
        
        function rollout = get_rollout(obj, index)
            
            rollout = obj.batch(index);
        end
        
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
        
        function arr = to_str_array(obj)
            
           for i = 1:obj.size
               
               arr(i) = obj.batch(i).to_struct();
           end
        end
    end
end
    
