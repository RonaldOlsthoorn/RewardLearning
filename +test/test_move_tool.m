arm = UR5.driver.URArm();
ip = '192.168.1.50';
arm.fopen(ip);

UR5.reset_arm(arm);
tolerance = 0.001;

for i = 1:3
    
    pause(1);
    arm.update();
    posFrom = arm.getToolPositions();
    posTo = posFrom;
    posTo(i) = posTo(i) + 0.2;
    arm.moveTool(posTo);
    
    y = posFrom(i);
    t = 0;
    pos = posFrom;
    
    t0 = tic;
    
    while abs(pos(i)-posTo(i)) > tolerance
        
        arm.update();
        pos = arm.getToolPositions();
        y(end+1) = pos(i);
        t(end+1) = toc(t0);
    end
    
    yBuf{i}.y_there = y;
    yBuf{i}.t = t;
    
    pause(1);
    arm.update();
    posFrom = arm.getToolPositions();
    posTo = posFrom;
    posTo(i) = posTo(i) - 0.2;
    arm.moveTool(posTo);
    
    y = posFrom(i);
    t = 0;
    pos = posFrom;
    
    t0 = tic;
    
    while abs(pos(i)-posTo(i)) > tolerance
        
        arm.update();
        pos = arm.getToolPositions();
        y(end+1) = pos(i);
        t(end+1) = toc(t0);
    end
    
    yBuf{i}.y_and_back_again = y;
    yBuf{i}.t = t;   
end
pause(1);
UR5.reset_arm(arm);