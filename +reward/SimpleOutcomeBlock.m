classdef SimpleOutcomeBlock < reward.OutcomeBlock
    % SIMPLEOUTCOMEEBLOCK feature block containing only squared error.
    
    properties
    end
    
    methods

        function obj = SimpleOutcomeBlock(reference)
            obj.reward_primitives = reward.outcome.OutcomeSquaredErrorTool(reference);
        end
    end
end

