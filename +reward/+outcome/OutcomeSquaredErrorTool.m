classdef OutcomeSquaredErrorTool < reward.outcome.Outcome
    % squared error reward feature function.
     
    properties
        
        ref;
    end
    
    methods
        
        function obj = OutcomeSquaredErrorTool(ref)
            
            obj.ref = ref;
        end
        
        % Returns the squared tracking error of the end effector (tool) 
        % as a reward primitive.
        function outcome = compute_outcome(obj, rollout)  
      
            outcome  = -sum((rollout.tool_positions'-obj.ref.r_tool').^2, 2);           
        end
    end
end
