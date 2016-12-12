classdef VPSegmentedOutcomeBlock < reward.OutcomeBlock
    % VPOUTCOMEEBLOCK feature block containing only squared error.
    
    properties
        
        n_segments;
        n;
    end
    
    methods
        
        function obj = VPSegmentedOutcomeBlock(ref)
            
           n = length(ref.t);
            
        end
        
        function init_segments(obj)
            
            segment = floor(obj.n/obj.n_segments);
            obj.segment_end = segment*(1:(obj.n_segments-1));
            obj.segment_start = obj.segment_end+1;
            
            obj.segment_start = [1 obj.segment_start];
            obj.segment_end = [obj.segment_end obj.n];
        end
        
        function obj = VPSegmentedOutcomeBlock()
            
            obj.reward_primitives = {reward.outcome.OutcomeVPX(), ...
                reward.outcome.OutcomeVPY()};
        end
    end
end