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
    end
    
end

