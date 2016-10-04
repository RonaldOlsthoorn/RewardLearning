function [ p ] = init_policy( policy_par, ref)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if(strcmp(policy_par.type, 'rbf'))
   
    p = policy.RBF_policy(policy_par, ref);
end


end

