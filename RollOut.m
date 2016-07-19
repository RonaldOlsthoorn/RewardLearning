classdef RollOut 
    
    properties
        iteration;
        index;
    end
    
    methods
        
        function obj = RollOut(iteration, index)
           obj.iteration = iteration;
           obj.index = index;
        end
        
        function res = equals(obj, in_ro)
                 
            if in_ro.iteration==obj.iteration...
                    && in_ro.index == obj.index
                res=true;
            else
                res=false;
            end
        end
        
    end
    
end

