classdef VPMultiSegmentExpert < expert.Expert
    % Implements a hard coded expert. Simple square error function is used.
    
    properties
        
        std; % rating error 
        n_segments;
        ref;
        
        segment_start;
        segment_end;
    end
    
    methods
        
        function obj = VPMultiSegmentExpert(s, ref, n)
            
            obj.std = s;
            obj.n_segments = n;
            obj.ref = ref;
            
            obj.init_segments();
        end
        
        function init_segments(obj)
            
            n = length(obj.ref.t);
            segment = floor(n/obj.n_segments);
            obj.segment_end = segment*(1:(obj.n_segments-1));
            obj.segment_start = obj.segment_end+1;
            
            obj.segment_start = [1 obj.segment_start];
            obj.segment_end = [obj.segment_end n];
        end
        
        function rating = query_expert(obj, rollout)
   
            rating = zeros(1, obj.n_segments);
            
            for i = 1:obj.n_segments
                
                for j = 1:length(obj.ref.viapoints(1,:))
                    
                    if obj.ref.viapoints_t(j)>= obj.segment_start(i) && ...
                            obj.ref.viapoints_t(j)<= obj.segment_end(i)
                        rating(i) = rating(i) - sum((rollout.tool_positions(:, obj.ref.viapoints_t(j))'...
                                    -obj.ref.viapoints(:,j)').^2, 2);  
                    end
                end
            end
            
            %rating = rating + obj.std*randn(1,obj.n_segments);
        end
    end
end