arm = UR5.driver.URArm();
ip = '192.168.1.50';
arm.fopen(ip);

UR5.reset_arm(arm);
tolerance = 0.001;
Ts = 0.01;

for i = 1:6
    
    arm.update();
    posFrom = arm.getJointsPositions();
    posTo = posFrom;
    posTo(i) = posTo(i) - pi/16;
    
    trajectory = posFrom(i):Ts:posTo(i);
    
    if i == 1
        trajectory = [ trajectory
            trajectory(i+1:end)*ones(1, length(trajectory) - i)];
    elseif i == 6
        
        trajectory = [ trajectory(1:i-1)*ones(1, i -1)
            trajectory];
    else
        
        trajectory = [ trajectory(1:i-1)*ones(1, i - 1)
            trajectory
            trajectory(i+1:end)*ones(1, length(trajectory) - i)];
    end
    
    y = posFrom(i);
    pos = posFrom;
    
    j=1;
    
    for j = 1:length(trajectory(1,:))
        
        t = tic;
        vel_d = (trajectory(:, j) - pos) / Ts;
        a_d = (vel_d - vel)/(0.1*Ts);
        arm.setJointsSpeed((trajectory(:, j) - pos) / Ts, a_d, Ts);
        
        while toc(t) < Ts
        end
        
        arm.update();
        pos = arm.getJointsPositions();
        vel = arm.getJointsPositions();
        y(end + 1) = pos(i);
    end
    
    bufPos{i} = y;
    
    pause(1);
end

pause(1);

UR5.reset_arm(arm);
arm.fclose();