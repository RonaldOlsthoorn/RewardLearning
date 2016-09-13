import dmp.*

clear; close all; clc;

arm = UR5.driver.URArm();
ip = '192.168.1.50';
arm.fopen(ip);

UR5.reset_arm(arm);
tolerance = 0.001;

i = 6;

a_tol = 2;
v_tol = 1;
Ts = 0.1;

arm.update();
posFrom = arm.getJointsPositions();
posTo = posFrom;
posTo(i) = posTo(i) - pi/8;
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
y_buf = posFrom(i);
t_buf = 0;

pos = posFrom;
vel = zeros(6, 1);
acc = zeros(6, 1);

a_buf = zeros(6, 1);
v_buf = zeros(6, 1);

for j = 2:length(y(:,1))
    
    a_d = (vel_d(:, j)-vel)/Ts;
%     a_d = a_buf(:, j);
    
    
    if a_d > a_tol
        a_d = a_tol;
        disp('Warning: acceleration limit reached!!');
    elseif a_d < -a_tol
        a_d = -a_tol;
        disp('Warning: acceleration limit reached!!');
    end
    
    v_d = (pos_d(:, j) - pos) / Ts;
%     v_d = v_buf(:, j)
    
    if v_d > v_tol
        v_d = v_tol;
        disp('Warning: velocity limit reached!!');
    elseif v_d < -v_tol
        v_d = -v_tol;
        disp('Warning: velocity limit reached!!');
    end
    
    a_d(2:6, 1) = 0;
    a_d = 0.1*a_d;
    v_d(1:5, 1) = 0;
    
    arm.setJointsSpeed(v_d, a_d, Ts);
    
    v_buf(:, j) = v_d;
    a_buf(:, j) = a_d;
    
    t = tic;
    
    while toc(t) < Ts
        pos = arm.getJointsPositions();
        t_buf(end + 1) = toc(t0);
        y_buf(end + 1) = pos(i);
        arm.update();
    end
    
    arm.update();
    pos = arm.getJointsPositions();
    vel = arm.getJointsPositions();
end

bufPos{i} = y_buf;