function [ ref ] = ref_trajectory( dmp_par )
%
t = 0:dmp_par.Ts:(dmp_par.duration-dmp_par.Ts);
goal = dmp_par.goal;
n_seg = floor(length(t)/4);
segment = t(n_seg);
n_end = floor(length(t)/2);

r = [ -0.5*goal+0.5*goal*cos(pi*t(1:n_seg)/(segment)),...
        -goal*cos(pi*(t(n_seg:n_end)-segment)/(segment))];
    
ref.r = [r goal*ones(1,length(t)-length(r))];
ref.r_d = [0 diff(ref.r)./dmp_par.Ts];
ref.r_dd = [0 diff(ref.r_d)./dmp_par.Ts];

end