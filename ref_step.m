function [ ref ] = ref_step( ro_par )
% returns a step function as reference.

t = 0:ro_par.Ts:(ro_par.duration-ro_par.Ts);
ref.r =  ro_par.goal*ones(1,length(t));
ref.r_d = zeros(1,length(t)); 
ref.r_dd = zeros(1,length(t)); 

end

