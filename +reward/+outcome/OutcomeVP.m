classdef OutcomeVP < reward.outcome.Outcome
    % viapoint error reward feature function.
     
    properties
        
        ref;
    end
    
    methods
        
        function obj = OutcomeVP(ref)
            
            obj.ref = ref;
        end
        
        function outcome = compute_outcome(obj, rollout)
            
            res = zeros(1, length(obj.ref.viapoints(1,:)));
            for i = 1:length(obj.ref.viapoints(1,:))
                res(i)  = -sum((rollout.tool_positions(:, obj.ref.viapoints_t(i))'...
                                    -obj.ref.viapoints(:,i)').^2, 2);           
            end
            
            outcome = sum(res);
        end
    end
end