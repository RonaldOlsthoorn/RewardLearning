function dx = eompend(x, r, control_method, par)
% Equations of motion for DCSC inverted pendulum setup

u = control_method(x, r);

dx = [  x(2,:);
        (-par.M*par.g*par.l*sin(x(1,:)) - ...
        (par.b + par.K^2/par.R)*x(2,:) + ...
        (par.K/par.R)*u)/par.J;
        r(1,:)-x(1,:)
     ];
        