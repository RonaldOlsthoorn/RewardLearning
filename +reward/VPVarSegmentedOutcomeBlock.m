classdef VPVarSegmentedOutcomeBlock < reward.OutcomeBlock
    % VPOUTCOMEBLOCK feature block containing only squared error.
    
    properties
        
        n_features = 4;
        segment_start;
        segment_end;
        n_segments;
        n;
    end
    
    methods
        
        function obj = VPVarSegmentedOutcomeBlock(ref, n_segments)
            
           obj.n = length(ref.t); 
           obj.n_segments = n_segments;
           obj.init_segments();
               
           obj.reward_primitives = {reward.outcome.OutcomeVPX(obj.segment_start, obj.segment_end), ...
                reward.outcome.OutcomeVPY(obj.segment_start, obj.segment_end), ...
                reward.outcome.OutcomeVPVarX(obj.segment_start, obj.segment_end), ...
                reward.outcome.OutcomeVPVarY(obj.segment_start, obj.segment_end)
                };
        end
        
        function init_segments(obj)
            
            segment = floor(obj.n/obj.n_segments);
            obj.segment_end = segment*(1:(obj.n_segments-1));
            obj.segment_start = obj.segment_end+1;
            
            obj.segment_start = [1 obj.segment_start];
            obj.segment_end = [obj.segment_end obj.n];
        end
        
        function outcomes = compute_outcomes(obj, rollout)
            % returns the outcome of the reward primitive functions, based
            % on the rollout (Rollout object).
            
            outcomes = zeros(obj.n_segments, length(obj.reward_primitives));
            
            for i = 1:length(obj.reward_primitives)
                outcomes(:,i) = obj.reward_primitives{i}.compute_outcome(rollout);
            end
        end
    end
end