classdef StaticEnvironment < environment.Environment
% Environment that has a static reward function. Only basic environment 
% functions are implemented.

    properties
    end
    
    methods
        
        function obj = StaticEnvironment(p, r)
            obj@environment.Environment(p, r);
        end
        
        function prepare(~)
        end
        
        function update_reward(~, ~)
        end
    end
    
end