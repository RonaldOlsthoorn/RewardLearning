function [ S ] = init_dmps_ik(S, dmp_par)

import dmp.DMP;

S = ik.map_ref(S, dmp_par, ik.create_model_UR5());

for i=1:dmp_par.n_dmps,                     % initialize DMPs
    
    S.dmps(i) = dmp.Exact_Timed_DMP(i, dmp_par);
    S.dmps(i).batch_fit(S.ref.r_joint(i,:)', S.ref.r_joint_d(i,:)', S.ref.r_joint_dd(i,:)');
end

end

