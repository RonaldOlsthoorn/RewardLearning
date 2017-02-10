classdef OutcomeVPVarY < reward.outcome.Outcome
    % viapoint error reward feature function.
    
    properties
        
        index = 2;
        
        segment_start;
        segment_end;
    end
    
    methods
                
        function obj = OutcomeVPVarY(ss, se)
            
            obj.segment_start = ss;
            obj.segment_end = se;
        end
                
        function outcome = compute_outcome(obj, rollout)
            
            outcome = zeros(length(obj.segment_start), 1);
            
            for i = 1:length(obj.segment_start)
                outcome(i,1) = var(rollout.tool_positions(obj.index, ...
                    obj.segment_start(i):obj.segment_end(i)));
                
                
            end
        end
    end
end