classdef SystemUR5 < plant.System
    
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
            
            obj.arm = UR5.driver.URArm();
            obj.init();
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
        
        function [joint_position, joint_speed,...
                tool_position, tool_speed] = run_increment(obj, control_input)
            
            t_init = tic;
            
            obj.arm.setJointsSpeed(control_input, obj.a, 2*obj.Ts);
            
            while toc(t_init)< obj.Ts;
            end
            
            obj.arm.update();
            
            joint_position = obj.arm.getJointsPositions();
            joint_speed = obj.arm.getJointsSpeeds();
            tool_position = obj.arm.getToolPositions();
            tool_speed = obj.arm.getToolSpeeds();
        end
        
        function [output] = reset(obj)
            
            tolerance = 0.001;
            
            pos0 = [0; -2*pi/3; 2*pi/3; 0; pi/2; 0];
            
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

