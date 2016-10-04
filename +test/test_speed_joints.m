clear; close all; clc;
import dmp.*

arm = UR5.driver.URArm();
ip = '192.168.1.50';
arm.fopen(ip);

UR5.reset_arm(arm);
tolerance = 0.001;

pause(1);

for i = 1:6;

v_tol = 0.3*ones(6, 1);
Ts = 0.1;

arm.update();
posFrom = arm.getJointsPositions();
posTo = posFrom;
posTo(i) = posTo(i) - pi/8;
duration = 4;

dmp_par.n_dmp_bf = 10;
dmp_par.Ts = Ts;
dmp_par.duration = duration;
dmp_par.start = posFrom(i);
dmp_par.goal = posTo(i);

dmp1 = Exact_Timed_DMP(i, dmp_par);
[y, yd, ydd] = dmp1.run(zeros(10, 1));

pos_d = posFrom*ones(1, length(y(:, 1)));
vel_d = zeros(6, length(y(:, 1)));
acc_d = zeros(6, length(y(:, 1)));

pos_d(i, :) = y;
vel_d(i, :) = yd;
acc_d(i, :) = ydd;

t0 = tic;
t_command = 0;
y_buf = posFrom;
t_buf = 0;
v_buf = zeros(6, 1);

Kp = 3;
Kd = 0.0375;

pos = posFrom;
vel = zeros(6, 1);

disp('into the movement loop');

for j = 2:length(y(:,1))
    
    a_d = 10;

    v_feed = Kp*(pos_d(:, j) - pos) + Kd*(vel_d(:, j) - vel);
    
    if v_feed(i) > v_tol(i)
        v_feed(i) = v_tol(i);
        disp('Warning: velocity limit reached!!');
    elseif v_feed(i) < -v_tol(i) 
        v_feed(i) = -v_tol(i);
        disp('Warning: velocity limit reached!!');
    end
        
    arm.setJointsSpeed(v_feed, a_d, Ts);
    
    t = tic;
    t_command(end + 1) = toc(t0);   
    v_buf(:, end + 1) = v_feed;
    
    while toc(t) < Ts    
    end
    
    arm.update();
    
    pos = arm.getJointsPositions();
    vel = arm.getJointsSpeeds();
    
    y_buf(:, end + 1) = pos;
    t_buf(end + 1) = toc(t0);
end

disp('out of the movement loop');

bufPos{i} = y_buf;
bufT{i} = t_buf;
bufV{i} = v_buf;

pause(1);

end

UR5.reset_arm(arm);
arm.fclose();

clear acc t_buf y_buf vel pos a_d v_d t t_command;
clear t0 y yd ydd i j;