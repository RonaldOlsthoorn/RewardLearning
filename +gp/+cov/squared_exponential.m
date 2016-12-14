classdef squared_exponential
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function res = k(~, X, hyp)
            
            lf = hyp(1);
            lx = hyp(2:end);
            Q = eye(2)*lx.^-2;
            %n = size(X,2);
            
            res = lf.*exp(X'*Q*X);
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
                
                dPdlxk = lx(k)*obj.k(X, hyp);
                dPdlxk = dPdlxk.*(X(k,:)'*ones(1,n)-ones(n,1)*X(k,:)/(lx(k)^2)).^2;
                                
                res(k) = 1/2*trace(R*dPdlxk);
            end
            
        end
        
        function res = deriv(obj, R, X, hyp)
            
            res = obj.dkdlf(X, hyp, R);
            res = [res; obj.dkdlx(X, hyp, R)];
        end      
    end
end
