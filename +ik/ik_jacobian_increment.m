function [ joints_end, tool_end ] = ik_jacobian_increment( model, tool_positions, joint_guess )

homogen = [0;0;0;1];
tool0 = model.fkine(joint_guess)*homogen;

alpha = 0.001;                      % state increment
epsilon=0.01;                      % error threshold

max_iterations = 100000;

tool_res = zeros(3, max_iterations);    % pre-allocate

tool = tool0(1:3);                     % initial end-effector
joints = joint_guess;                  % initial state

i=0;

while(norm(tool_positions-tool,2)>epsilon && i< max_iterations)
    
    i=i+1;
    tool_res(:,i)=tool;
    
    delta_tool = alpha*(tool_positions-tool)/norm(tool_positions-tool);
    
    J = model.jacobn(joints);
    
    delta_joints = pinv(J)*delta_tool;
    joints = delta_joints+joints;
    
    tool = model.fkine(joint_guess)*homogen;
    tool = tool(1:3);
end

if(i==max_iterations)
    disp('no solution found');
end

joints_end = joints;
tool_end = tool;

end

