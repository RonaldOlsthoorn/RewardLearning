function dx = eompend(x, r, control_method, arm)
% Equations of motion for DCSC inverted pendulum setup

u = control_method(x, r);

dx = [  x(2,:);
        (-arm.M*arm.g*arm.l*sin(x(1,:)) - ...
        (arm.b + arm.K^2/arm.R)*x(2,:) + ...
        (arm.K/arm.R)*u)/arm.J;
        r(1,:)-x(1,:)
     ];
        