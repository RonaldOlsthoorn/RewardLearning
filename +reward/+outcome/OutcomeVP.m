classdef OutcomeVP < reward.outcome.Outcome
    % squared error reward feature function.
     
    properties
        
        ref;
    end
    
    methods
        
        function obj = OutcomeVP(ref)
            
            obj.ref = ref;
        end
        
        function outcome = compute_outcome(obj, rollout)
            % returns the squared tracking error as a reward primitive.
      
            outcome  = -sum((rollout.tool_positions(:, obj.ref.vp_t)'-obj.ref.vp').^2, 2);           
        end
    end
end
