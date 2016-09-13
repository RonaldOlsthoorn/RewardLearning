import dmp.*

clear; close all; clc;

arm = UR5.driver.URArm();
ip = '192.168.1.50';
arm.fopen(ip);

UR5.reset_arm(arm);
tolerance = 0.001;

pause(1);

i = 1;

a_tol = 2;
v_tol = 1;
Ts = 0.1;

arm.update();
posFrom = arm.getToolPositions();
posTo = posFrom;
posTo(i) = posTo(i) + 0.1;
duration = 2;

dmp_par.n_dmp_bf = 10;
dmp_par.Ts = Ts;
dmp_par.duration = 4;
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
y_buf = posFrom(i);
t_buf = 0;

pos = posFrom;
vel = zeros(6, 1);
acc = zeros(6, 1);

for j = 2:length(y(:,1))
    
    a_d = (vel_d(:, j)-vel)/(2*Ts);
    
    if a_d > a_tol
        a_d = a_tol;
        disp('Warning: acceleration limit reached!!');
    elseif a_d < -a_tol
        a_d = -a_tol;
        disp('Warning: acceleration limit reached!!');
    end
    
    v_d = (pos_d(:, j) - pos) / Ts;
    
    if v_d > v_tol
        v_d = v_tol;
        disp('Warning: velocity limit reached!!');
    elseif v_d < -v_tol
        v_d = -v_tol;
        disp('Warning: velocity limit reached!!');
    end
    
    arm.setJointsSpeed((pos_d(:, j) - pos) / Ts, a_d, Ts);
    
    t = tic;
    t_command(end + 1) = toc(t0);
    
    while toc(t) < Ts
        pos = arm.getToolPositions();
        t_buf(end + 1) = toc(t0);
        y_buf(end + 1) = pos(i);
        arm.update();
    end
    
    arm.update();
    pos = arm.getToolPositions();
    vel = arm.getToolSpeeds();
end

bufPos{i} = y_buf;
bufT{i} = t_buf;

pause(1);
UR5.reset_arm(arm);
pause(1);

UR5.reset_arm(arm);
arm.fclose();