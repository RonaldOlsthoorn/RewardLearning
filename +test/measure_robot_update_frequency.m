arm = UR5.driver.URArm();
ip = '192.168.1.50';
arm.fopen(ip);

UR5.reset_arm(arm);
tolerance = 0.001;

pause(1);
arm.update();
posFrom = arm.getJointsPositions();
posTo = posFrom;
posTo(1) = posTo(1) - pi/16;
arm.moveJoints(posTo);

y = posFrom(1);
t = 0;
pos = posFrom;

t0 = tic;

while abs(pos(1)-posTo(1)) > tolerance
    
    arm.update();
    pos = arm.getJointsPositions();
    y(end+1) = pos(1);
    t(end+1) = toc(t0);
    
end

y_filtered = y(1);
t_filtered = t(1);

for i = 1:length(y)
    
    if abs(y(i) - y_filtered(end)) > 0.0001
        y_filtered(end+1) = y(i);
        t_filtered(end+1) = t(i);
    end
end

diff_t = diff(t_filtered);
frequency = 1/(mean(t_filtered(2:end)));

disp(strcat('Robot update frequency: ', num2str(frequency)));
pause(1);
UR5.reset_arm(arm);