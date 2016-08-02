function [ ref ] = ref_trajectory2( D )
%
t = D.t;
goal = D.goal;
duration = D.duration;
t_end = find(t>duration, 1);
segment = duration/2;
t_seg = find(t>segment, 1);


ref = [ -0.5*goal+0.5*goal*cos(pi*t(1:t_seg)/(segment)),...
        -goal*cos(pi*(t(t_seg:t_end)-segment)/(segment)),...
        goal*ones(1,length(t)-t_end-1)];

end

