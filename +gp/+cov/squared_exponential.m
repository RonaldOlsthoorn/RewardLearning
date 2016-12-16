classdef squared_exponential
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function res = k(~, X, hyp)
            
            lf = hyp(1);
            lx = hyp(2:end);
            [d, n] = size(X);
            
            res = zeros(n);
            
            for i = 1:d
                
                diff = repmat(X(i,:),n,1) - repmat(X(i,:)',1,n);
                res = res + diff.*(lx(i)^-2).*diff;       
            end
            
            res = lf.*res;
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
