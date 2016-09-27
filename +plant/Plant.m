classdef Plant < handle
    
    properties
        
        system;
        controller;
    end
    
    methods
        
        function obj = Plant(s, c)
            
            obj.system = s;
            obj.controller = c;
        end
        
        function rollout = run(reference)
            
        end
        
        function batch_rollouts = batch_run(batch_reference)
            
            for i = 1:length(batch_reference)
                batch_rollouts = run(batch_reference(i));
            end 
        end 
    end    
end

