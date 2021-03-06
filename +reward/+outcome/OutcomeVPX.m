classdef OutcomeVPX < reward.outcome.Outcome
    % End effector x position mean outcome function.
    
    properties
        
        index = 1;
        segment_start;
        segment_end;
    end
    
    methods
        
        function obj = OutcomeVPX(ss, se)
            
            obj.segment_start = ss;
            obj.segment_end = se;
        end
                
        % Compute end effector x position mean as outcome.
        % rollout: input trajectory for which outcome has to be calculated.        
        function outcome = compute_outcome(obj, rollout)
            
            outcome = zeros(length(obj.segment_start), 1);
            
            for i = 1:length(obj.segment_start)
                outcome(i,1) = mean(rollout.tool_positions(obj.index, ...
                    obj.segment_start(i):obj.segment_end(i)));
            end
        end
    end
end