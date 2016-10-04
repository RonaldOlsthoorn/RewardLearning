classdef RewardPrimitiveAbsErrorTool < reward.primitive.RewardPrimitive
    
    properties
        
        ref;
    end
    
    methods
        
        function obj = RewardPrimitiveAbsErrorTool(ref)
            
            obj.ref = ref;
        end
        
        function outcome = compute_outcome(rollout)
            
            % Implements a simple squared error cost function.
            % Struct S: Result of roll-outs.
            % Struct ro_par: rollout parameters.
            
            % Cost during trajectory
            outcome  = -sum(abs((rollout.ef_positions(1:3,:)'-obj.ref.r_tool(:,1:3))), 2);
            
        end
    end
end
