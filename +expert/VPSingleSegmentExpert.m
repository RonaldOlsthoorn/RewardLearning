classdef VPSingleSegmentExpert < expert.Expert
    % Implements a hard coded expert. Simple square error function is used.
    
    properties
        
        manual = false;
        std; % rating error 
        ref;
    end
    
    methods
        
                
        % Constructor.
        % s: standard deviation expert noise.
        % ref: object containing viapoints.
        function obj = VPSingleSegmentExpert(s, ref)
            
            obj.std = s;
            obj.ref = ref;
        end
        
        % Computes the expert rating. Expert noise included.
        % rollout: end effector trajectory to be rated.
        % rating: expert rating.
        function rating = query_expert(obj, rollout)
   
            res = zeros(1, length(obj.ref.viapoints(1,:)));
            for i = 1:length(obj.ref.viapoints(1,:))
                res(i)  = -sum((rollout.tool_positions(:, obj.ref.viapoints_t(i))'...
                                    -obj.ref.viapoints(:,i)').^2, 2);           
            end
            
            rating = sum(res);
            
            rating = rating + obj.std*rand;
        end
        
        % Computes the expert rating. Expert noise excluded.
        % rollout: end effector trajectory to be rated.
        % rating: expert rating.
        function rating = true_reward(obj, rollout)
   
            res = zeros(1, length(obj.ref.viapoints(1,:)));
            for i = 1:length(obj.ref.viapoints(1,:))
                res(i)  = -sum((rollout.tool_positions(:, obj.ref.viapoints_t(i))'...
                                    -obj.ref.viapoints(:,i)').^2, 2);           
            end
            
            rating = sum(res);
            
        end
    end
end