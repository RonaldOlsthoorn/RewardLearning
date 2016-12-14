classdef quadratic
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function res = k(~, X, hyp)
            
            Kw = hyp(1);
            
            [d, n] = size(X);
            
            res = zeros(n);
            
            for i = 1:n
                res(((i-1)*d+1):i*d,:) = X(:,i)'*Kw*X;
            end
        end
        
        function res = dkdlf(X, hyp)
            
            lf = hyp(1);
            lx = hyp(2);
            n = size(X,2);
            diff = repmat(X,n,1) - repmat(X',1,n);
            res = 2*lf*exp(-1/2*diff.^2/lx^2);
        end
        
        function res = dkdlx(X, hyp)
            
            lx = hyp(2);
            n = size(X,2);
            diff = repmat(X,n,1) - repmat(X',1,n);
            res = k(X, hyp)*(diff.^2)*(lx^(-3));
        end
        
    end
    
end
