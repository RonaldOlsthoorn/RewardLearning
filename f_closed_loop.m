function [xnext] = f_closed_loop(x, r, sim_par)
% for a single state, x is a row vector, 
%   otherwise it is a matrix with the individual state vectors in rows
% for a single input u is a row vector (or scalar for SI systems), 
%   otherwise it is a matrix with individual input vectors in rows

t = 0:sim_par.Ts/2:sim_par.Ts;

%[~,y]= ode45(@(t,y)ode45_wrapper(t,y,r,control_method),t, x );

y = ode4_ti('eompend',t, x, r, sim_par.controller, sim_par.arm);

y = y(end,:);           % we are only interested in the last value

if sim_par.wrapflag,
    if y(1) > pi,  y(1) = y(1) - 2*pi; end; % wrapping
    if y(1) < -pi, y(1) = y(1) + 2*pi; end; % wrapping
end;

xnext = y;