classdef VPAdvancedSingleSegmentExpert < expert.Expert
    % Implements a hard coded expert. Simple square error function is used.
    
    properties
        
        manual = false;
        std; % rating error 
        ref;
        
        threshold = 0.9;
        penalty = 10;
        
        w_plane = 2;
        w_point = 1;
    end
    
    methods
        
        % Constructor.
        % s: standard deviation expert noise.
        % ref: object containing viapoints.
        function obj = VPAdvancedSingleSegmentExpert(s, ref)
            
            obj.std = s;
            obj.ref = ref;
        end
        
        % Computes the expert rating. Expert noise included.
        % rollout: end effector trajectory to be rated.
        % rating: expert rating.
        function rating = query_expert(obj, rollout)
   
            res = 0;
            
            [m_sing] = max(sqrt(sum(rollout.tool_positions.^2)));
            
            if m_sing > obj.threshold
                 res = res - obj.penalty;
            end
            
            sq_error = (rollout.tool_positions(:, obj.ref.plane.t/obj.ref.Ts)...
                -obj.ref.plane.tool).^2;
            sq_error(isnan(sq_error)) = 0;
            
            res = res - obj.w_plane*sum(sum(sq_error,2));
                
            for i = 1:length(obj.ref.viapoints(1,:))
                res  = res -obj.w_point*sum((rollout.tool_positions(:, obj.ref.viapoints_t(i))'...
                                    -obj.ref.viapoints(:,i)').^2, 2);           
            end
            
            rating = res + obj.std*randn;
        end
        
        % Computes the expert rating. Expert noise excluded.
        % rollout: end effector trajectory to be rated.
        % rating: expert rating. 
        function rating = true_reward(obj, rollout)
   
            res = 0;
            
            [m_sing] = max(sqrt(sum(rollout.tool_positions.^2)));
            
            if m_sing > obj.threshold
                 res = res - obj.penalty;
            end
            
            sq_error = (rollout.tool_positions(:, obj.ref.plane.t/obj.ref.Ts)...
                -obj.ref.plane.tool).^2;
            sq_error(isnan(sq_error)) = 0;
            
            res = res - obj.w_plane*sum(sum(sq_error,2));
                
            for i = 1:length(obj.ref.viapoints(1,:))
                res  = res -obj.w_point*sum((rollout.tool_positions(:, obj.ref.viapoints_t(i))'...
                                    -obj.ref.viapoints(:,i)').^2, 2);           
            end
            
            rating = res;
        end
    end
end