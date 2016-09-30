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
            
            trajectory.control_input = zeros(obj.system.dof, length(trajectory.xd(1,:)));
            trajectory.joint_positions = zeros(obj.system.dof, length(trajectory.xd(1,:)));
            trajectory.joint_speeds = zeros(obj.system.dof, length(trajectory.xd(1,:)));
            trajectory.tool_positions = zeros(obj.system.dof, length(trajectory.xd(1,:)));
            trajectory.tool_speeds = zeros(obj.system.dof, length(trajectory.xd(1,:))); 
            
            r = zeros(obj.system.dof, length(trajectory.dof(1).xd(1,:)));
            rd = zeros(obj.system.dof, length(trajectory.dof(1).xd(1,:)));
            
            for i=1:obj.system.dof
                
                r(i,:) = trajectory.dof(i).xd(1,:);
                rd(i,:) = trajectory.dof(i).xd(2,:);
                
            end
            
            output = obj.system.reset();
            
            for i = 1:length(trajectory.xd(1,:))
                
                control_input = obj.controller.control_law(r(:,i), rd(:,i),... 
                                    output.joint_position, output.joint_speed);
                                
                output = obj.system.run_increment(control_input);
                
                trajectory.control_input(:,i) = control_input;
                trajectory.joint_positions(:,i) = output.joint_position;
                trajectory.joint_speeds(:,i) = output.joint_speed;
                trajectory.tool_positions(:,i) = output.tool_position;
                trajectory.tool_speeds(:,i) = output.tool_speed;
             
            end
            
            rollout = trajectory;
            
        end
        
        function batch_rollouts = batch_run(obj, batch_trajectories)
            
            for i = 1:length(batch_trajectories)
                batch_rollouts = obj.run(batch_trajectories(i));
            end
        end
    end
end

