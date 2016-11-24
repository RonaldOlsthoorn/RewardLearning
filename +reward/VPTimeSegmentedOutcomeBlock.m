classdef VPTimeSegmentedOutcomeBlock< reward.OutcomeBlock
    % VPOUTCOMEEBLOCK feature block containing only squared error.
    
    properties
    end
    
    methods

        function obj = VPTimeSegmentedOutcomeBlock(reference)
            obj.reward_primitives = reward.outcome.OutcomeVP(reference);
        end
    end
end