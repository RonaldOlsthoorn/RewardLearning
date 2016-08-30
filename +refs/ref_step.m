function [ ref ] = ref_step( dmp_par )
% returns a step function as reference.

t = 0:dmp_par.Ts:(dmp_par.duration-dmp_par.Ts);

ref.r =  dmp_par.goal*ones(1,length(t));
% ref.r(2) = 0.5*(dmp_par.goal-dmp_par.start);
% ref.r(1) = dmp_par.start;

ref.r_d = [0 diff(ref.r)./dmp_par.Ts];
ref.r_dd = [0 diff(ref.r_d)./dmp_par.Ts];

end

