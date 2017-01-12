function [xnext] = f_closed_loop(x,r, control_method, par)
% for a single state, x is a row vector, 
%   otherwise it is a matrix with the individual state vectors in rows
% for a single input u is a row vector (or scalar for SI systems), 
%   otherwise it is a matrix with individual input vectors in rows

global Ts wrapflag

t = 0:Ts/2:Ts;

y = ode4_ti('eompend',t, x, r, control_method, par);
y = y(end,:);           % we are only interested in the last value

if wrapflag
    if y(1) > pi,  y(1) = y(1) - 2*pi; end; % wrapping
    if y(1) < -pi, y(1) = y(1) + 2*pi; end; % wrapping
end;

xnext = y;