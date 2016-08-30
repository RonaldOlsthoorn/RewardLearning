function dx = eompend(x, r, control_method, arm)
% Equations of Motion for DCSC inverted pendulum setup.
% x: column vector containing the state of the system.
% r: column vector containing the reference.
% control_method: handle to the controller of the system.
% arm: struct containing all the robot arm parameters.

u = control_method(x, r);

dx = [  x(2,:);
        (-arm.M*arm.g*arm.l*sin(x(1,:)) - ...
        (arm.b + arm.K^2/arm.R)*x(2,:) + ...
        (arm.K/arm.R)*u)/arm.J;
        r(1,:)-x(1,:)
     ];
        