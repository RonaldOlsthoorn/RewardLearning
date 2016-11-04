function [ x_ef ] = forward_kinematics(x, par)
% Returns the cartesian coordinates of the end effector
% as function of the state and the parameters.

x_end       = par.l1*cos(x(1,:))+par.l2*cos(x(1,:)+x(3,:));
x_vel_end   = -(par.l1*sin(x(1,:))+par.l2*sin(x(1,:)+x(3,:))).*x(2,:)...
                -par.l2*sin(x(1,:)+x(3,:)).*x(4,:);
y_end       = par.l1*sin(x(1,:))+par.l2*sin(x(1,:)+x(3,:));
y_vel_end   = (par.l1*cos(x(1,:))+par.l2*cos(x(1,:)+x(3,:))).*x(2,:)...
                +par.l2*cos(x(1,:)+x(3,:)).*x(4,:);

x_ef        = [x_end; x_vel_end; y_end; y_vel_end]; 
end