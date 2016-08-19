function [ u ] = perfect_controller( x, r )
% Controller for trajectory tracking. Not really perfect PID controller,
% but good enough.
% x: state vector (column)
% r: reference vector (column)

Kd = 10;
Ki = 5;
Kp = 1000;

u = Kp*(r(1,:)-x(1,:))+Ki*(x(3,:))+Kd*(r(2,:)-x(2,:));

end

