function [ ref ] = ref_trajectory_cart(reference)
% Generates a trajectory in cartesian space. velocity and
% acceleration trajectory also included

global Ts;
t = D.t;
amp  = 0.25;
surface = 0.75;
segment = D.duration/3;

n_seg1 = find(t>segment, 1);
n_seg2 = find(t>2*segment, 1);
t_end = D.n_end;
dx = (0.8)/(t_end-1);

r = 0.625+0.5*amp*sin(pi*(t(1:n_seg1)-0.5*segment)/(segment));
r = [r, surface*ones(1,n_seg2-n_seg1-3)];
r = [r, r(n_seg1:-1:1)];
r = [r, 0.5*ones(1,length(t)-t_end)];

r = [0:dx:0.8, 0.8*ones(1,length(t)-t_end);r];

r_d = [[0;0], [diff(r(1,:)); diff(r(2,:))]./Ts];
r_dd = [[0;0], [diff(r_d(1,:)); diff(r_d(2,:))]./Ts];

ref.r = r;
ref.r_d = r_d;
ref.r_dd = r_dd;

ref.n_seg1 = n_seg1;
ref.n_seg2 = n_seg2;
end

