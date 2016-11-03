function [ p ] = init_policy(policy_par, ref)
% returns the policy parameterization.
% policy_par: tuning parameters of the policy.

switch policy_par.type
    case 'rbf_ff'
        p = policy.RBF_ff_policy(policy_par, ref);
    case 'rbf_ref'
        p = policy.RBF_ref_policy(policy_par, ref);
    otherwise
        p = [];
end

end

