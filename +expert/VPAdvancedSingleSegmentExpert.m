classdef VPAdvancedSingleSegmentExpert < expert.Expert
    % Implements a hard coded expert. Simple square error function is used.
    
    properties
        
        manual = false;
        std; % rating error 
        ref;
    end
    
    methods
        
        function obj = VPAdvancedSingleSegmentExpert(s, ref)
            
            obj.std = s;
            obj.ref = ref;
        end
        
        function rating = query_expert(obj, rollout)
   
            res = zeros(1, length(obj.ref.viapoints(1,:)));
            
            res = res - mean(...
                (rollout.tool_positions(:, obj.ref.plane.t)...
                -obj.ref.viaplane').^2, 2) + ...
                obj.std*randn();
                
            for i = 1:length(obj.ref.viapoints(1,:))
                res(i)  = -sum((rollout.tool_positions(:, obj.ref.viapoints_t(i))'...
                                    -obj.ref.viapoints(:,i)').^2, 2);           
            end
            
            rating = sum(res);
            rating = rating + obj.std*rand;
        end
        
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