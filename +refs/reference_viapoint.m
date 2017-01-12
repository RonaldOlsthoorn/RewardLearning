function [r] = reference_viapoint(reference_par)
% Generates a trajectory in cartesian space. velocity and
% acceleration trajectory also included

Ts = reference_par.Ts;
t = 0:Ts:reference_par.duration-Ts;

r = zeros(2, length(t));
r(:, reference_par.viapoint_t) = reference_par.viapoint;

end