function [ joints, tool ] = getJointsAndPositions()

arm = UR5.driver.URArm();
ip = '192.168.1.50';
arm.fopen(ip);
arm.update();

joints = arm.getJointsPositions();
tool   = arm.getToolPositions();


end

