classdef HardCodedExpert < expert.Expert
    % Implements a hard coded expert. Simple square error function is used.
    
    properties
        
        std; % rating error 
    end
    
    methods
        
        % Constructor.
        % standard_deviation: represents expert rating error std.
        function obj = HardCodedExpert(standard_deviation)
            
            obj.std = standard_deviation;
        end
        
        function rating = query_expert(obj, rollout)
            
            rating = obj.std*randn()+sum(rollout.outcomes);
        end
    end
end

