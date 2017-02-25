function [ p ] = init_policy(policy_par, ref)
% returns the policy parameterization.
% policy_par: tuning parameters of the policy.

switch policy_par.type
    case 'rbf_ff' % policy = ref+ff(theta). ff built with rbf's
        p = policy.RBF_ff_policy(policy_par, ref);
    case 'rbf_ref' % policy = ref(theta). ref built with rbf's
        p = policy.RBF_ref_policy(policy_par, ref);
    case 'dmp_ref' % dmp's in joint space.
        p = policy.DMP_policy(policy_par, ref);
    case 'dmp_ref_ik' % dmp's in end effector space
        p = policy.DMP_policy_ik(policy_par, ref);
    case 'UR5_dmp_ref' % dmp's in joint space.
        p = policy.UR5_DMP_policy(policy_par, ref);
    case 'UR5_dmp_ref_ik'% dmp's in end effector space
        p = policy.UR5_DMP_policy_ik(policy_par, ref);
        
    otherwise
        p = [];
end

end