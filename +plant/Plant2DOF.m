classdef Plant2DOF < plant.Plant
    
    properties(Constant)
        
        handle_batch_figure = 1;
    end
    
    properties

    end
    
    methods
        
        function obj = Plant2DOF(plant_par, external_controller)
            
            system = plant.System2DOF(plant_par);
            
            
            controller = external_controller;
            obj@plant.Plant(system, controller);
        end
        
        function rollout = run(obj, trajectory)
            
            n_end = length(trajectory.policy.dof(1).xd(1,:));
            
            control_input = zeros(obj.system.dof, n_end);
            joint_positions = zeros(obj.system.dof, n_end);
            joint_speeds = zeros(obj.system.dof, n_end);
            tool_positions = zeros(obj.system.dof, n_end);
            tool_speeds = zeros(obj.system.dof, n_end);
            time = zeros(1, n_end);
            
            r = zeros(obj.system.dof, n_end);
            rd = zeros(obj.system.dof, n_end);
            
            for i=1:obj.system.dof
                
                r(i,:) = trajectory.policy.dof(i).xd(1,:);
                rd(i,:) = trajectory.policy.dof(i).xd(2,:);
            end
            
            output = obj.system.reset();
            
            joint_position = output.joint_position;
            joint_speed = output.joint_speed;
                        
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
                        
            trajectory.control_input = control_input;
            trajectory.joint_positions = joint_positions;
            trajectory.joint_speeds = joint_speeds;
            trajectory.tool_positions = tool_positions;
            trajectory.tool_speeds = tool_speeds;
            trajectory.time = time;
            
            rollout = trajectory;
        end        
        
    end
end

