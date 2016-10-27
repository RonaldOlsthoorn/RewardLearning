classdef HardCodedExpert < expert.Expert
    %UNTITLED5 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        
        function rating = query_expert(~, rollout)
            
            rating = sum(rollout.outcomes);
        end
    end
    
end

