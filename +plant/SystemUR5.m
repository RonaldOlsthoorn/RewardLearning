classdef SystemUR5 < plant.System
    
    properties(Constant)
        
        ip = '192.168.1.50';
        a = 10;
        
    end
    
    properties
        
        arm;
        
        Ts;
        
    end
    
    methods
        
        function obj = SystemUR5()
            
            % obj.arm = UR5.driver.URArm();
            obj.init();
            
        end
        
        function connect(obj)
            
            obj.arm.fopen(obj.ip);
            
        end
        
        function disconnect(obj)
            
            obj.arm.fopen(obj.ip);
        end
        
        function output = run_increment(control_input)
            
            obj.arm.setJointSpeeds(control_input, obj.a, obj.Ts);
            obj.arm.update();
            
            output.joint_position = obj.arm.getJointsPositions();
            output.joint_speed = obj.arm.getJointsSpeeds();
            output.tool_position = obj.arm.getToolPositions();
            output.tool_speed = obj.arm.getToolSpeeds();
            
        end
        
        function init(obj)
            
            obj.connect();
        end
        
        function [output] = reset(obj)
            
            obj.gently_break();
            
            tolerance = 0.001;
            
            pos0 = [0; -2*pi/3; 2*pi/3; 0; pi/2; 0];
            
            obj.arm.update();
            pos = obj.arm.getJointsPositions();
            
            for i = 1:6
                pos(i) = pos0(i);
                
                obj.arm.moveJoints(pos);
                pos = obj.arm.getJointsPositions();
                
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

