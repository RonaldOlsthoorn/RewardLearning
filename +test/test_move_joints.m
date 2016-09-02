arm = UR5.driver.URArm();
ip = '192.168.1.50';
arm.fopen(ip);

UR5.reset_arm(arm);
tolerance = 0.001;

for i = 1:6
    
    arm.update();
    posFrom = arm.getJointsPositions(); 
    posTo = posFrom;
    posTo(i) = posTo(i) - pi/16;
    arm.moveJoints(posTo);
    
    y = posFrom(i);
    pos = posFrom;
    
    while abs(pos(i)-posTo(i)) > tolerance
        
        arm.update();
        pos = arm.getJointsPositions();
        y(end+1) = pos(i);
    end
    
    bufPos{i} = y;
end