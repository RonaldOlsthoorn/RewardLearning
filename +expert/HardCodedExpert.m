classdef HardCodedExpert < expert.Expert
    % Implements a hard coded expert. Simple square error function is used.
    
    properties
        
        std; % rating error 
    end
    
    methods
        
        function obj = HardCodedExpert(s)
            
            obj.std = s;
        end
        
        function rating = query_expert(obj, rollout)
            
            rating = obj.std*randn()+sum(rollout.outcomes);
        end
    end
end

