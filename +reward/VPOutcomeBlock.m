classdef VPOutcomeBlock < reward.OutcomeBlock
    % VPOUTCOMEEBLOCK feature block containing only end effector mean.
    
    properties
        
        n_segments;
        n;
    end
    
    methods
        
        function obj = VPOutcomeBlock(ref)
            
            obj.n = length(ref.t);
            obj.reward_primitives = {reward.outcome.OutcomeVPX(), ...
                reward.outcome.OutcomeVPY()};
            
            obj.init_segments();
        end
        
        % Initialize segment start and end time indices.
        function init_segments(obj)
            
            segment = floor(obj.n/obj.n_segments);
            obj.segment_end = segment*(1:(obj.n_segments-1));
            obj.segment_start = obj.segment_end+1;
            
            obj.segment_start = [1 obj.segment_start];
            obj.segment_end = [obj.segment_end obj.n];
        end
        
    end
end