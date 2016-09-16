function [ ref ] = ref_robot(dmp_par)
%
t = 0:dmp_par.Ts:(dmp_par.duration-dmp_par.Ts);
goal = dmp_par.goal_tool;
start = dmp_par.start_tool;
n_seg = floor(length(t)/4);
segment = t(n_seg);
n_end = floor(length(t)/2);

y = [ -0.5*goal(2)+0.5*goal(2)*cos(pi*t(1:n_seg)/(segment)),...
    -goal(2)*cos(pi*(t(n_seg:n_end)-segment)/(segment))];

y = y + start(2);

x = dmp_par.start(1):(dmp_par.goal(1)-dmp_par.start(1))/(length(y)-1):dmp_par.goal(1);
z = dmp_par.start(3)*ones(1,length(t));
    
ref.r_tool = [x goal(1)*ones(1,length(t)-length(x))
              y goal(2)*ones(1,length(t)-length(y));
              z];
          
ref.r_tool_d = [[0; 0; 0],diff(ref.r_tool./dmp_par.Ts, 1, 2)];

ref.r_tool_dd = [[0; 0; 0],diff(ref.r_tool_d./dmp_par.Ts, 1, 2)];
end