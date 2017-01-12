classdef MultiSegmentExpert < expert.Expert
    % Implements a hard coded expert. Simple square error function is used.
    
    properties
        
        std; % rating error 
        n_segments;
        weights  = [1 1 1 1];
    end
    
    methods
        
        function obj = MultiSegmentExpert(s, n)
            
            obj.std = s;
            obj.n_segments = n;
        end
        
        function rating = query_expert(obj, rollout)
   
            rating = obj.weights.*rollout.sum_out;
            % rating  = rating + obj.std*randn(1, 4);
        end
    end
end