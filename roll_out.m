classdef roll_out 
    % Container class used as a fancy struct.
    properties
        iteration;
        index;
        dmp;
        q;
        u;
        outcomes;
        sum_out;
        r;
        R;
        R_expert;
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

