classdef OutcomeAbsErrorTool < reward.outcome.Outcome
    % absolute error reward feature function.
    
    properties
        
        ref;
    end
    
    methods
        
        function obj = OutcomeAbsErrorTool(ref)
            
            obj.ref = ref;
        end
        
        function outcome = compute_outcome(rollout)
            % returns the absolute tracking error as a reward primitive.
            
            outcome  = -sum(abs((rollout.ef_positions(1:3,:)'-obj.ref.r_tool(:,1:3))), 2);
        end
    end
end
