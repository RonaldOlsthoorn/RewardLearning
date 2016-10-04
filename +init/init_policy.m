function [ p ] = init_policy(policy_par, ref)
% returns the policy parameterization.
% policy_par: tuning parameters of the policy.

if(strcmp(policy_par.type, 'rbf'))
   
    p = policy.RBF_policy(policy_par, ref);
end


end

