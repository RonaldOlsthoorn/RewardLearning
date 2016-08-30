function [ u ] = lousy_controller( x, r )
% Controller for trajectory tracking. Not at all a perfect PID controller,
% used to show the power of PI2 learning.
% x: state vector (column)
% r: reference vector (column)

Kd = 0.5;
Ki = 10;
Kp = 10;

u = Kp*(r(1,:)-x(1,:))+Ki*(x(3,:))+Kd*(r(2,:)-x(2,:));

end
