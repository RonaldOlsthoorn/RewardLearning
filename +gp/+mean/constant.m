function [ m ] = constant( X, hyp )
%CONSTANT Summary of this function goes here
%   Detailed explanation goes here

if length(hyp) ~= length(X(:,1))
    error('hyper parameter dimension mismatch');
end

m = ones(length(X(1,:)), 1)*hyp';

end

