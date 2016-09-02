arm = UR5.driver.URArm();
ip = '192.168.1.50';
arm.fopen(ip);

UR5.reset_arm(arm);
pause(1);

tolerance = 0.001;

pos0 = arm.getToolPosition();
posPath(:, 1) = pos0;
posPath(1, 1) = posPath(1, 1)+0.03;
posPath(:, 2) = posPath(:, 1);
posPath(1, 2) = posPath(1, 2)+0.03;
posPath(:, 3) = posPath(:, 2);
posPath(1, 3) = posPath(1, 3)+0.03;

t = tic;
y = pos0(1,1);

for i = 1:3
    
    arm.moveTool(posPath(:,i));
    
    while toc(t) < Ts
        arm.update();
        pos = arm.getToolPosition();
        y(end+1) = pos(1,1);
    end
    
    t = tic;
end

pause(1);
UR5.reset_arm(arm);
arm.fclose();