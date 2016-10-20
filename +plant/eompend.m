function dx = eompend(x, r, control_method, par)
% Equations of motion for a double pendulum. Derivations based on Lagrangian.
% Source: http://divf.eng.cam.ac.uk/birl/pub/Main/Publications/LataniotisC.pdf

alpha = par.Iz1+par.Iz2+par.m1*par.r1^2 + par.m2*(par.l1^2 + par.r2^2);
beta = par.m2*par.l1*par.r2;
delta = par.Iz2 + par.m2*par.r2^2;

M = [alpha+2*beta*cos(x(3,:)), delta+beta*cos(x(3,:)) 
    delta+beta*cos(x(3,:)), delta];         % Mass matrix

C = [-beta*sin(x(3,:))*x(4,:)+par.b1, -beta*sin(x(3,:))*(x(2,:)+x(4,:))
    beta*sin(x(3,:))*x(2,:), par.b2];       % Coriolis and damping matrix

G = [par.m1*par.g*par.r1*cos(x(1,:))+par.m2*par.g*(par.l1*cos(x(1,:))+par.r2*cos(x(1,:)+x(3,:)))
    2*par.m2*par.g*par.r2*cos(x(1,:)+x(3,:))];     % Gravity matrix

u = control_method(x, r, M, C, G);

dx = (M)\(u-C*[x(2,:); x(4,:)]-G); 
dx = [x(2,:); dx(1,:); x(4,:); dx(2,:)];