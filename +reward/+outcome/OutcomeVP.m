classdef OutcomeVP < reward.outcome.Outcome
    % viapoint error reward feature function.
    
    properties
        
        viapoint;
    end
    
    methods
        
        function obj = OutcomeVP(viapoint)
            
            obj.viapoint = viapoint;
        end
        
        function outcome = compute_outcome(obj, rollout)
            
            outcome = -sum((rollout.tool_positions' - ...
                ones(length(rollout.tool_positions(1,:)), 1)*obj.viapoint').^2, 2);
        end
    end
end