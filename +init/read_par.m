function [ par ] = read_par
% returns the configuration of the robotic arm in a single struct.
par.J = 1.91e-4;    % Pendulum inertia
par.M = 5.5e-2;     % Pendulum mass
par.g = 9.81;       % Gravity constant
par.l = 4.2e-2;     % Pendulum length
par.b = 3e-6;       % Viscous damping
par.K = 5.36e-2;    % Torque constant
par.R = 9.5;        % Rotor resistance

end

