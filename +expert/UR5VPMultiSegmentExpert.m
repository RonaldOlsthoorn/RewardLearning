classdef UR5VPMultiSegmentExpert < expert.Expert
    % Implements a hard coded expert. Simple square error function is used.
    
    properties
        
        std; % rating error 
        n_segments;
        ref;
        
        segment_start;
        segment_end;
    end
    
    methods
        
        % Constructor.
        % s: standard deviation expert noise.
        % ref: object containing viapoints.
        % n: number of segments.
        function obj = UR5VPMultiSegmentExpert(s, ref, n)
            
            obj.std = s;
            obj.n_segments = n;
            obj.ref = ref;
            
            obj.init_segments();
        end
        
        % Initializes start and end indices of segments.
        function init_segments(obj)
            
            n = length(obj.ref.t);
            segment = floor(n/obj.n_segments);
            obj.segment_end = segment*(1:(obj.n_segments-1));
            obj.segment_start = obj.segment_end+1;
            
            obj.segment_start = [1 obj.segment_start];
            obj.segment_end = [obj.segment_end n];
        end
        
        % Computes the expert rating. Expert noise included.
        % rollout: end effector trajectory to be rated.
        % rating: expert rating.
        function rating = query_expert(obj, rollout)
   
            rating = zeros(1, obj.n_segments);
            
            for i = 1:obj.n_segments
                
                for j = 1:length(obj.ref.viapoints(1,:))
                    
                    if obj.ref.viapoints_t(j)>= obj.segment_start(i) && ...
                            obj.ref.viapoints_t(j)<= obj.segment_end(i)
                        rating(i) = rating(i) - sum((rollout.tool_positions(1:3, obj.ref.viapoints_t(j))'...
                                    -obj.ref.viapoints(1:3,j)').^2, 2);  %only position is interesting. orientation care we do not!
                    end
                end
            end
            
            %rating = rating + obj.std*randn(1,obj.n_segments);
        end
    end
end