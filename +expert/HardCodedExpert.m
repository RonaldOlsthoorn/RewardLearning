classdef HardCodedExpert < expert.Expert
    %UNTITLED5 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        std;
    end
    
    methods
        
        function obj = HardCodedExpert(s)
            
            obj.std = s;
        end
        
        function rating = query_expert(obj, rollout)
            
            rating = obj.std*randn()+rollout.sum_out;
        end
    end
end

