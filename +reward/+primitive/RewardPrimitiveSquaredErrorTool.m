classdef RewardPrimitiveSquaredErrorTool < reward.primitive.RewardPrimitive
    % squared error reward primitive.
     
    properties
        
        ref;
    end
    
    methods
        
        function obj = RewardPrimitiveSquaredErrorTool(ref)
            
            obj.ref = ref;
        end
        
        function outcome = compute_outcome(obj, rollout)
            % returns the squared tracking error as a reward primitive.
      
            outcome  = -sum((rollout.tool_positions'-obj.ref.r_tool').^2, 2);           
        end
    end
end
