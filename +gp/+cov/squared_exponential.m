function [ cov ] = squared_exponential( X, hyp )
%SQUARED_EXPONENTIAL Summary of this function goes here
%   Detailed explanation goes here

lf = hyp(1);
lx = hyp(2);

n = size(X,2);
diff = repmat(X,n,1) - repmat(X',1,n);
cov = lf^2*exp(-1/2*diff.^2/lx^2);

end