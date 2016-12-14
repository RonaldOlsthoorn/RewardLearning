classdef linear
    
    properties
    end
    
    methods
        
        function [res] = linear(~, X, hyp)
            
            w = eye(length(hyp))*hyp;
            res = X'*w;
        end
    end
end