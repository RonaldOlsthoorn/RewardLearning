clear; close all; clc;

arm = UR5.driver.URArm();
ip = '192.168.1.50';
arm.fopen(ip);

mdl_UR5;

UR5.reset_arm(arm);
arm.update();

posTool1 = arm.getToolPositions()

qz = [0; (-pi/2); 0; 0; 0; 0];  
fkinematics = model_UR5.fkine(qz)

pos = arm.getJointsPositions();
pos0 = qz
tolerance = 0.001;

for i = 6:-1:1
    pos(i) = pos0(i);
    
    arm.moveJoints(pos);
    pos = arm.getJointsPositions();
    
    while abs(pos(i)-pos0(i)) > tolerance
        
        pause(1)
        arm.update();
        pos = arm.getJointsPositions();
    end
    
end

posTool2 = arm.getToolPositions()
fkinematics = model_UR5.fkine(pos0)