arm = UR5.driver.URArm();
ip = '192.168.1.50';
arm.fopen(ip);

UR5.reset_arm(arm);
tolerance = 0.001;

i = 1;

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

j = arm.getJointsPositions();

while abs(pos(i)-posTo(i)) > tolerance
    
    arm.update();
    pos = arm.getToolPositions();
    j(:,end+1) = arm.getJointsPositions();
    y(end+1) = pos(i);
    t(end+1) = toc(t0);
end

yBuf{i}.y_there = y;
yBuf{i}.j_there = j;

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

clear j;
j = arm.getJointsPositions();

while abs(pos(i)-posTo(i)) > tolerance
    
    arm.update();
    pos = arm.getToolPositions();
    j(:,end+1) = arm.getJointsPositions();
    y(end+1) = pos(i);
    t(end+1) = toc(t0);
end

yBuf{i}.y_and_back_again = y;
yBuf{i}.t = t;
yBuf{i}.j_and_back_again = j;

pause(1);
UR5.reset_arm(arm);