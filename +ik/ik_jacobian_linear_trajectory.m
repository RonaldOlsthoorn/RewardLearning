function [joints, tool] = ik_jacobian_linear_trajectory(model, tool_start, tool_end, joint_guess)

increments = 10;
tool_waypoints = zeros(3, increments);

for i=1:3
    
    if tool_start(i)-tool_end(i)==0
        tool_waypoints(i,:) = tool_start(i);       
    else
        tool_waypoints(i,:) = (tool_start(i):(tool_end(i)-tool_start(i))/(increments-1):tool_end(i))';
    end
end

joints = zeros(6, increments);
tool = zeros(3, increments);

[j, t] = ik.find_initial_joints(model, tool_start(1:3), joint_guess);
joints(:,1) = j;
tool(:,1) = t;

for i = 2:increments
    
    [j,t] = ik.ik_jacobian_increment(model, tool_waypoints(:,i-1), joints(:,i-1));
    
    joints(:,i) = j;
    tool(:,i) = t;
end

