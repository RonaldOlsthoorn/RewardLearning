classdef affine
    
    properties
    end
    
    methods
        
        function [res] = m(~, X, hyp)
            
            [d, ~] = size(X);
            
            mbar = hyp(end).*ones(d,1);
            w = eye(d)*hyp(1,end-1);
            res = X'*w+mbar;
        end
        
        function res = deriv(~, X, fm, hyp)
            
            res = X'*P\(fm-obj.m(X,hyp));
            res(end+1) = ones(1,length(X(:,1)))*P\(fm-obj.m(X,hyp));
        end
        
        function hyp = optimize_hyper(~, P, X, fm) 
            
            hyp = (X'*P\fm)./(X'*P\X);
            hyp(end+1) = (ones(1,length(X(:,1)))'*P\fm)./...
                (ones(1,length(X(:,1)))'*P\ones(1,length(X(:,1))));
        end
        
    end
    
end