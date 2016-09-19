function [ ref ] = map_ref(ref, model_UR5)

T1 = transl(ref.r_tool(:,1));
T2 = transl(ref.r_tool(:,end));
T = ctraj(T1, T2, length(ref.r_tool(1,:))); 	% compute a Cartesian path
q = model_UR5.ikine(T, 'pinv'); 

figID = 1;
figure(double(figID));
set(double(figID), 'units','normalized','outerposition',[0 0 1 1]);
clf;
model_UR5.plot(q);

T_back_again = model_UR5.fkine(q);

ref.r_joint = q;
ref.r_joint_d = [];
ref.r_joint_dd = [];


% Inverse kinematics function, based on the Jacobian method.
% theta0: initial state in state-space
% xgoal: desired end state of the end-effector in cartesian space
% par: struct containing the parameters of the robotic arm

% theta_end: end state in state-space
% x_res: trajectory of the end-effector

% Calculate the initial end-effector coordinates (Cartesian)




alpha = 0.001;                      % state increment
epsilon=0.001;                      % error threshold

max_iterations = 100000;

x_res = zeros(2,max_iterations);    % pre-allocate

x = [x0(1);x0(3)];                        % initial end-effector
theta = theta0;                     % initial state

i=0;

while(norm(xgoal-x,2)>epsilon && i< max_iterations)
    
    i=i+1;
    x_res(:,i)=x;
    
    delta_x = alpha*(xgoal-x)/norm(xgoal-x);
    
    J = [-par.l1*sin(theta(1))-par.l2*sin(theta(1)+theta(2)),...
        -par.l2*sin(theta(1)+theta(2));
        par.l1*cos(theta(1))+par.l2*cos(theta(1)+theta(2)),...
        par.l2*cos(theta(1)+theta(2))];
    
    delta_theta = pinv(J)*delta_x;
    theta = delta_theta+theta;
    
    [x_end] = forward_kinematics([theta(1);0;theta(2);0], par);
    x = [x_end(1);x_end(3)];
    
end

if(i==max_iterations)
    disp('no solution found');
end

theta_end = theta;

end



end

