classdef PlantUR5 < plant.Plant
    
    properties(Constant)
        
        handle_batch_figure = 4;
    end
    
    properties

    end
    
    methods
        
        function obj = PlantUR5(plant_par, external_controller)
            
            if ~plant_par.sim
                system = plant.SystemUR5(plant_par);
            else
                system = [];
            end
            
            controller = external_controller;
            obj@plant.Plant(system, controller);
        end
        
        function set_init_state(obj, is)
            
            obj.system.set_init_state(is)
        end
        
        function rollout = run(obj, trajectory)
            
            n_end = length(trajectory.policy.dof(1).xd(1,:));
            
            control_input = zeros(obj.system.dof, n_end);
            joint_positions = zeros(obj.system.dof, n_end);
            joint_speeds = zeros(obj.system.dof, n_end);
            tool_positions = zeros(3, n_end);
            tool_speeds = zeros(3, n_end);
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
            
            pause(0.1);
            
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
            obj.system.reset();
            
            trajectory.control_input = control_input;
            trajectory.joint_positions = joint_positions;
            trajectory.joint_speeds = joint_speeds;
            trajectory.tool_positions = tool_positions;
            trajectory.tool_speeds = tool_speeds;
            trajectory.time = time;
            
            rollout = trajectory;
        end   
        
        function print_rollout(obj, rollout)
            
            figure(obj.handle_batch_figure)
            subplot(1,3,1)
            hold on
            plot(rollout.time, rollout.tool_positions(1,:));
            subplot(1,3,2)
            hold on
            plot(rollout.time, rollout.tool_positions(2,:));
            subplot(1,3,3)
            hold on
            plot(rollout.time, rollout.tool_positions(3,:));
        end   
        
    end
end

