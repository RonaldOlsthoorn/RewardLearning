classdef squared_exponential
    % obsolete.

    properties
    end
    
    methods
        function res = k(~, X, hyp)
            
            lf = hyp(1);
            lx = hyp(2:end);
            [~, n] = size(X);
            Q = diag(lx.^-2);
            
            res = zeros(n);
            
            for i=1:n
                for j=1:n
                    res(i,j) = (lf^2)*exp((-1/2)*(X(:,i)-X(:,j))'*Q*(X(:,i)-X(:,j)));
                end
            end
            
        end
        
        function res = dkdlf(obj, X, hyp, R)
            
            lf = hyp(1);
            dPdlf = (2/lf)*obj.k(X,hyp);
            res = 1/2*trace(R*dPdlf);
        end
        
        function res = dkdlx(obj, X, hyp, R)
            
            lx = hyp(2:end);
            n = size(X,2);
            
            res = zeros(length(lx),1);
            
            for k = 1:length(lx)
                
                diff = repmat(X(k,:),n,1) - repmat(X(k,:)',1,n);             
                res(k) = 1/(2*lx(k)^3)*trace(R*(obj.k(X, hyp).*(diff.^2)));
            end
            
        end
        
        function res = deriv(obj, R, X, hyp)
            
            res = obj.dkdlf(X, hyp, R);
            res = [res; obj.dkdlx(X, hyp, R)];
        end      
    end
end
