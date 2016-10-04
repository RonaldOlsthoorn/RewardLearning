function [ S ] = init_dmps_ik(S, dmp_par)

import dmp.DMP;

S = ik.map_ref(S, dmp_par, ik.create_model_UR5());
dmp_par.ref = S.ref.r_joint;

for i=1:dmp_par.n_dmps, % initialize DMPs
    
    S.dmps(i) = dmp.RBF_policy(i, dmp_par);
    S.dmps(i).batch_fit(S.ref.r_joint(i,:)');
end

end

