classdef Plant2DOF < plant.Plant
    % 2DoF robotic arm simulator+controller
    
    properties(Constant)
        
        handle_batch_figure = 4;
    end
    
    properties
    end
    
    methods
        
        function obj = Plant2DOF(system, external_controller)
                       
            controller = external_controller;
            obj@plant.Plant(system, controller);
        end
        
        % run rollout with prescribed trajectory.
        function rollout = run(obj, trajectory)
            
            n_end = length(trajectory.policy.dof(1).xd(1,:));
            
            % pre allocate memmory
            control_input = zeros(obj.system.dof, n_end);
            joint_positions = zeros(obj.system.dof, n_end);
            joint_speeds = zeros(obj.system.dof, n_end);
            tool_positions = zeros(obj.system.dof, n_end);
            tool_speeds = zeros(obj.system.dof, n_end);
            
            r = trajectory.policy.r;
            rd = trajectory.policy.rd;
            rdd = trajectory.policy.rdd;
            
            output = obj.system.reset();
            obj.controller.reset();
            
            joint_position = output.joint_position;
            joint_speed = output.joint_speed;
                                    
            for i = 1:length(trajectory.policy.dof(1).xd(1,:))
                
                u = obj.controller.control_law(r(:,i), rd(:,i), rdd(:,i), ...
                    joint_position, joint_speed);
                
                [joint_position, joint_speed,...
                    tool_position, tool_speed] = obj.system.run_increment(u);
            
                control_input(:,i) = u;
                joint_positions(:,i) = joint_position;
                joint_speeds(:,i) = joint_speed;
                tool_positions(:,i) = tool_position;
                tool_speeds(:,i) = tool_speed;                    
            end
                        
            trajectory.control_input = control_input;
            trajectory.joint_positions = joint_positions;
            trajectory.joint_speeds = joint_speeds;
            trajectory.tool_positions = tool_positions;
            trajectory.tool_speeds = tool_speeds;
            % swap rollout/trajectory
            rollout = trajectory;
        end 
        
        function set_init_state(obj, s)
            
            obj.system.set_init_state(s);
        end
        
        % print the rollout in the manner that best fits this system.
        function print_rollout(obj, rollout)
            
            figure(obj.handle_batch_figure)
            subplot(1,3,1)            
            hold on
            plot(rollout.time, rollout.tool_positions(1,:));
            xlabel('t [s]');
            ylabel('x_{ef} [m]');
            subplot(1,3,2)
            hold on
            plot(rollout.time, rollout.tool_positions(2,:));
            xlabel('t [s]');
            ylabel('y_{ef} [m]');
            subplot(1,3,3)
            hold on
            plot(rollout.tool_positions(1,:), rollout.tool_positions(2,:));
            xlabel('x_{ef} [m]');
            ylabel('y_{ef} [m]');
            drawnow;
        end        
    end
end