function [ S ] = init_dmps( S, dmp_par )

import dmp.DMP;

for i=1:dmp_par.n_dmps,                     % initialize DMPs
    
    S.dmps(i) = dmp.Exact_Timed_DMP(i, dmp_par);
    S.dmps(i).batch_fit(S.ref.r(i,:)', S.ref.r_d(i,:)', S.ref.r_dd(i,:)');
end

end

