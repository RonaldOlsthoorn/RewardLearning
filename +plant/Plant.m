classdef Plant < handle
    
    properties
        
        system;
        controller;
    end
    
    methods
        
        function obj = Plant(s, c)
            
            obj.system = s;
            obj.controller = c;
        end
        
        function rollout = run(obj, trajectory)
            
            control_input = zeros(obj.system.dof, length(trajectory.policy.dof(1).xd(1,:)));
            joint_positions = zeros(obj.system.dof, length(trajectory.policy.dof(1).xd(1,:)));
            joint_speeds = zeros(obj.system.dof, length(trajectory.policy.dof(1).xd(1,:)));
            tool_positions = zeros(obj.system.dof, length(trajectory.policy.dof(1).xd(1,:)));
            tool_speeds = zeros(obj.system.dof, length(trajectory.policy.dof(1).xd(1,:)));
            time = zeros(1, length(trajectory.policy.dof(1).xd(1,:)));

            r = zeros(obj.system.dof, length(trajectory.policy.dof(1).xd(1,:)));
            rd = zeros(obj.system.dof, length(trajectory.policy.dof(1).xd(1,:)));
            
            for i=1:obj.system.dof
                
                r(i,:) = trajectory.policy.dof(i).xd(1,:);
                rd(i,:) = trajectory.policy.dof(i).xd(2,:);
                
            end
            
            output = obj.system.reset();
            joint_position = output.joint_position;
            joint_speed = output.joint_speed;
            
            pause(0.1)
            
            t0 = tic;
            
            for i = 1:length(trajectory.policy.dof(1).xd(1,:))
                
                control_input = obj.controller.control_law(r(:,i), rd(:,i),... 
                                    joint_position, joint_speed);
                                
                [joint_position, joint_speed,...
                    tool_position, tool_speed] = obj.system.run_increment(control_input);
                
                control_input(:,i) = control_input;
                joint_positions(:,i) = joint_position;
                joint_speeds(:,i) = joint_speed;
                tool_positions(:,i) = tool_position;
                tool_speeds(:,i) = tool_speed;
                
                time(1,i) = toc(t0);
             
            end
            
            obj.system.gently_break();
            
            trajectory.control_input = control_input;
            trajectory.joint_positions = joint_positions;
            trajectory.joint_speeds = joint_speeds;
            trajectory.tool_positions = tool_positions;
            trajectory.tool_speeds = tool_speeds;
            trajectory.time = time;
            
            rollout = trajectory;
            
        end
        
        function batch_rollouts = batch_run(obj, batch_trajectories)
            
            for i = 1:length(batch_trajectories)
                disp(strcat('Sample nr : ', num2str(i)));
                batch_trajectories(i) = obj.run(batch_trajectories(i));
            end
            
            batch_rollouts = batch_trajectories;
        end
    end
end

