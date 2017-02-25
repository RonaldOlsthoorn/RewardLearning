classdef VPAdvancedXMultiSegmentExpert < expert.Expert
    % Implements a hard coded expert. Simple square error function is used.
    
    properties
        
        std; % rating error
        n_segments;
        ref;
        
        segment_start;
        segment_end;
        
        manual = false;
        
        threshold = 0.9;
        penalty = 10;
        
        w_plane = 1;
        w_point = 1;
    end
    
    methods
        
        % Constructor.
        % s: standard deviation, aka expert rating error.
        % ref: struct containing info about viapoint(s) and viaplane.
        % n: number of segments        
        function obj = VPAdvancedXMultiSegmentExpert(s, ref, n)
            
            obj.std = s;
            obj.n_segments = n;
            obj.ref = ref;
            
            obj.init_segments();
        end
        
        % Initializes start and end indexes according to the number of
        % segments chosen.        
        function init_segments(obj)
            
            n = length(obj.ref.t);
            segment = floor(n/obj.n_segments);
            obj.segment_end = segment*(1:(obj.n_segments-1));
            obj.segment_start = obj.segment_end+1;
            
            obj.segment_start = [1 obj.segment_start];
            obj.segment_end = [obj.segment_end n];
        end
        
        % Returns the expert rating of a rollout. All segments are rated.  
        % @return: vector containing ratings for each segment accordingly.        
        function rating = query_expert(obj, rollout)
            
            rating = zeros(1, obj.n_segments);
            
            for i = 1:obj.n_segments
                
                [m_sing] = max(sqrt(sum(rollout.tool_positions(:, obj.segment_start(i):obj.segment_end(i)).^2)));
                
                if m_sing > obj.threshold
                    rating(i) = rating(i) - obj.penalty;
                end
                
                if obj.ref.plane.t(1)>= obj.segment_start(i)*obj.ref.Ts && ...
                        obj.ref.plane.t(2)<= obj.segment_end(i)*obj.ref.Ts
                    
                    sq_error = (rollout.tool_positions(:, obj.segment_start(i):obj.segment_end(i))...
                        -obj.ref.plane.tool).^2;
                    sq_error(isnan(sq_error)) = 0;
                    
                    rating(i) = rating(i) - obj.w_plane*sum(sum(sq_error,2)) + obj.std*randn();
                end
                
                for j = 1:length(obj.ref.viapoints(1,:))
                    
                    if obj.ref.viapoints_t(j)>= obj.segment_start(i) && ...
                            obj.ref.viapoints_t(j)<= obj.segment_end(i)
                        rating(i) = rating(i) - obj.w_point*sum((rollout.tool_positions(:, obj.ref.viapoints_t(j))'...
                            -obj.ref.viapoints(:,j)').^2, 2) + ...
                            obj.std*randn();
                    end
                end
            end
        end
        
        % Returns the 'true' underlying reward of a rollout. Comes down to
        % the expert rating without expert noise.        
        function rating = query_expert_segment(obj, rollout, seg)
            
            rating = zeros(1, obj.n_segments);
            
            [m_sing] = max(sqrt(sum(rollout.tool_positions(:, obj.segment_start(seg):obj.segment_end(seg)).^2)));
            
            
            if m_sing > obj.threshold
                rating(seg) = rating(seg) - obj.penalty;
            end
            
            if obj.ref.plane.t(1)>= obj.segment_start(seg)*obj.ref.Ts && ...
                    obj.ref.plane.t(2)<= obj.segment_end(seg)*obj.ref.Ts
                
                sq_error = (rollout.tool_positions(:, obj.segment_start(seg):obj.segment_end(seg))...
                    -obj.ref.plane.tool).^2;
                sq_error(isnan(sq_error)) = 0;
                
                rating(seg) = rating(seg) - obj.w_plane*sum(sum(sq_error,2)) + obj.std*randn();
            end
            
            for j = 1:length(obj.ref.viapoints(1,:))
                
                if obj.ref.viapoints_t(j)>= obj.segment_start(seg) && ...
                        obj.ref.viapoints_t(j)<= obj.segment_end(seg)
                    rating(seg) = rating(seg) - obj.w_point*sum((rollout.tool_positions(:, obj.ref.viapoints_t(j))'...
                        -obj.ref.viapoints(:,j)').^2, 2) + ...
                        obj.std*randn();
                end
            end
        end
        
        function rating = true_reward(obj, rollout)
            
            rating = zeros(1, obj.n_segments);
            
            for seg = 1:obj.n_segments
                
                [m_sing] = max(sqrt(sum(rollout.tool_positions(:, obj.segment_start(seg):obj.segment_end(seg)).^2)));
                
                if m_sing > obj.threshold
                    rating(seg) = rating(seg) - obj.penalty;
                end
                
                if obj.ref.plane.t(1)>= obj.segment_start(seg)*obj.ref.Ts && ...
                        obj.ref.plane.t(2)<= obj.segment_end(seg)*obj.ref.Ts
                    
                    sq_error = (rollout.tool_positions(:, obj.segment_start(seg):obj.segment_end(seg))...
                        -obj.ref.plane.tool).^2;
                    sq_error(isnan(sq_error)) = 0;
                    
                    rating(seg) = rating(seg) - obj.w_plane*sum(sum(sq_error,2));
                end
                
                for j = 1:length(obj.ref.viapoints(1,:))
                    
                    if obj.ref.viapoints_t(j)>= obj.segment_start(seg) && ...
                            obj.ref.viapoints_t(j)<= obj.segment_end(seg)
                        rating(seg) = rating(seg) - obj.w_point*sum((rollout.tool_positions(:, obj.ref.viapoints_t(j))'...
                            -obj.ref.viapoints(:,j)').^2, 2) ;
                    end
                end
            end
        end
    end
end