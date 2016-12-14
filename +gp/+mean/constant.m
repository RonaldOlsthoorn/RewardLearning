classdef constant
    
    properties
    end
    
    methods
        
        function [res] = m(~, X, hyp)
           
            res = ones(length(X(1,:)), 1).*hyp;            
        end
        
        function [res] = deriv(obj, X, fm, P, hyp)
            
            res = ones(1,length(X(:,1)))*P\(fm-obj.m(X,hyp)); 
        end
        
        function hyp = optimize_hyper(~, P, X, fm) 
            
            hyp = (ones(1,length(X(:,1)))'*P\fm)./...
                (ones(1,length(X(:,1)))'*P\ones(1,length(X(:,1))));
        end
    end   
end