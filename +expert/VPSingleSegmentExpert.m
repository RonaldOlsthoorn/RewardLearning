classdef VPSingleSegmentExpert < expert.Expert
    % Implements a hard coded expert. Simple square error function is used.
    
    properties
        
        manual = false;
        std; % rating error 
        ref;
    end
    
    methods
        
        % Constructor.
        % s: standard deviation, aka expert rating error.
        % ref: struct containing info about viapoint(s) and viaplane.
        function obj = VPSingleSegmentExpert(s, ref)
            
            obj.std = s;
            obj.ref = ref;
        end
        
        % Returns the expert rating of a rollout. All segments are rated.  
        % @return: vector containing ratings for each segment accordingly.        
        function rating = query_expert(obj, rollout)
   
            res = zeros(1, length(obj.ref.viapoints(1,:)));
            for i = 1:length(obj.ref.viapoints(1,:))
                res(i)  = -sum((rollout.tool_positions(:, obj.ref.viapoints_t(i))'...
                                    -obj.ref.viapoints(:,i)').^2, 2);           
            end
            
            rating = sum(res);
            
            rating = rating + obj.std*rand;
        end
        
        % Returns the 'true' underlying reward of a rollout. Comes down to
        % the expert rating without expert noise.        
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