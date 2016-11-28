classdef VPOutcomeBlock< reward.OutcomeBlock
    % VPOUTCOMEEBLOCK feature block containing only squared error.
    
    properties
    end
    
    methods
        
        function obj = VPOutcomeBlock(reference)
            
            for i = 1:length(reference.viapoints(1,:))
                
                vp = reference.viapoints(:,i);
                obj.reward_primitives = [obj.reward_primitives, ...
                    reward.outcome.OutcomeVP(vp)];
            end
        end
    end
end