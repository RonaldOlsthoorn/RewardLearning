classdef SystemUR5 < plant.System
% Wrapper class for ur5 robotic commands.

    properties(Constant)
        
        ip = '192.168.1.50';
        a = 10;
    end
    
    properties
        
        arm;
        Ts;
        dof = 6;
    end
    
    methods
        
        function obj = SystemUR5(system_par)
            
            obj.Ts = system_par.Ts;
            
%             obj.arm = UR5.driver.URArm();
%             obj.init();
        end
        
        % sets initial state for rollouts (joint positions).
        function set_init_state(obj, is)
            
            obj.init_state = is;
        end
        
        function init(obj)
            
            obj.connect();
        end
        
        function connect(obj)
            
            obj.arm.fopen(obj.ip);
        end
        
        function disconnect(obj)
            
            obj.arm.fopen(obj.ip);
        end
        
        % Runs a time step on the robotic arm of Ts seconds. 
        function [joint_position, joint_speed,...
                tool_position, tool_speed] = run_increment(obj, control_input)
            
            t_init = tic;
            
            obj.arm.setJointsSpeed(control_input, obj.a, 2*obj.Ts);
            
            while toc(t_init)< obj.Ts
            end
            
            obj.arm.update();
            
            joint_position = obj.arm.getJointsPositions();
            joint_speed = obj.arm.getJointsSpeeds();
            tp = obj.arm.getToolPositions();
            tool_position = tp(1:3)';
            ts = obj.arm.getToolSpeeds();
            tool_speed = ts(1:3)';
        end
        
        % Place the robot arm in its initial position.
        function [output] = reset(obj)
            
            tolerance = 0.001;
            
            pos0 = obj.init_state;
            
            obj.arm.update();
            pos = obj.arm.getJointsPositions();
            
            for i = 1:6
                pos(i) = pos0(i);
                
                obj.arm.moveJoints(pos);
                pos = obj.arm.getJointsPositions();
                vel = obj.arm.getJointsSpeeds();
                
                while abs(pos(i)-pos0(i)) > tolerance
                    
                    pause(1)
                    obj.arm.update();
                    pos = obj.arm.getJointsPositions();
                    vel = obj.arm.getJointsSpeeds();
                end
                
            end
            
            output.joint_position = pos;
            output.joint_speed = vel;
        end
        
        % Make all the joints stop its movements easily.
        function gently_break(obj)
            
            obj.arm.update();
            s = obj.arm.getJointsSpeeds();
            obj.arm.setJointsSpeed([0;0;0;0;0;0], 0.5, 1);
            
            tol = 0.001;
            
            while norm(s) > tol
                obj.arm.update();
                pause(0.1)
                s = obj.arm.getJointsSpeeds();
                
            end
        end
    end
end

