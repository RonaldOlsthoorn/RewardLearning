function [ r, r_d, r_dd ] = ref_2doflin(reference_par)
% Generates a trajectory in cartesian space. velocity and
% acceleration trajectory also included

Ts = reference_par.Ts;

t = 0:Ts:reference_par.duration-Ts;
n_end = length(t);

r(1,:) = reference_par.start_tool(1):(reference_par.goal_tool(1)-reference_par.start_tool(1))/(n_end-1):reference_par.goal_tool(1);
r(2,:) = ones(1,n_end)*reference_par.start_tool(2);

r_d = [[0;0], [diff(r(1,:)); diff(r(2,:))]./Ts];
r_dd = [[0;0], [diff(r_d(1,:)); diff(r_d(2,:))]./Ts];
end

