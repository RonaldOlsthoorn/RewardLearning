classdef StaticEnvironment < environment.Environment
    
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

