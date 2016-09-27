classdef SystemUR5 < plant.System
    
    properties(Constant)
        
        ip = '192.168.1.50';

    end
    
    properties
       
        arm;
        
    end
    
    methods
        
        function obj = SystemUR5()
            
            % obj.arm = UR5.driver.URArm();
            
        end
        
        function connect(obj)
            
            obj.arm.fopen(obj.ip);
            
        end
        
        function disconnect(obj)
            
            obj.arm.fopen(obj.ip);
        end
        
        function output = run_increment(control_input)
            
            obj.arm.setJointSpeeds(control_input);
            obj.arm.update();
            
        end
    end
    
end

