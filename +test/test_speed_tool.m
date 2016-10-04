import dmp.*

clear; close all; clc;

arm = UR5.driver.URArm();
ip = '192.168.1.50';
arm.fopen(ip);

UR5.reset_arm(arm);
tolerance = 0.001;

pause(1);

i = 1;

a = 1;
v_tol = 1*ones(6, 1);
Ts = 0.1;

arm.update();
posFrom = arm.getToolPositions();
posTo = posFrom;
posTo(i) = posTo(i) - 0.1;
duration = 8;

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
a_buf = zeros(1, 1);

pos = posFrom;
vel = zeros(6, 1);

disp('into the movement loop');

for j = 2:length(y(:, 1))
    
    a_d = 1;
    
    v_d = (pos_d(:, j) - pos) / Ts;
    
    if v_d(i) > v_tol(i)
        v_d(i) = v_tol(i);
        disp('Warning: velocity limit reached!!');
    elseif v_d(i) < -v_tol(i) 
        v_d(i) = -v_tol(i);
        disp('Warning: velocity limit reached!!');
    end
        
    arm.setToolSpeed(v_d, a_d, Ts);
    
    t = tic;
    t_command(end + 1) = toc(t0);
    
    v_buf(:, end + 1) = v_d;
    a_buf(1, end + 1) = a_d;
    
    while toc(t) < Ts
       
    end
    
    arm.update();
    
    pos = arm.getToolPositions();
    vel = arm.getToolSpeeds();
    
    y_buf(:, end + 1) = pos;
    t_buf(end + 1) = toc(t0);
end

disp('out of the movement loop');

bufPos{i} = y_buf;
bufT{i} = t_buf;
bufV{i} = v_buf;
bufA{i} = a_buf;

pause(1);

UR5.reset_arm(arm);
arm.fclose();

clear acc t_buf y_buf vel pos a_d v_d t t_command;
clear t0 y yd ydd i j;