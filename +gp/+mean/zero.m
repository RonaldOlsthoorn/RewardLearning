classdef zero
    % obsolete.

    properties
    end
    
    methods
        
        function [res] = m(~, X, ~)
            
            res = zeros(length(X(1,:)),1);           
        end
        
        function res = deriv(~, ~, ~, ~)
            
            res = [];
        end
        
        function hyp = optimize_hypers(~, ~, ~, ~) 
            
            hyp = [];
        end
    end
end