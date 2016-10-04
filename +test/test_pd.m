clear; close all; clc;
import dmp.*

arm = UR5.driver.URArm();
ip = '192.168.1.50';
arm.fopen(ip);

UR5.reset_arm(arm);
tolerance = 0.001;

pause(1);

for i = 6:-1:1;

v_tol = 0.3*ones(6, 1);
Ts = 0.01;

arm.update();
posFrom = arm.getJointsPositions();
posTo = posFrom;
posTo(i) = posTo(i) - 0.1;
duration = 4;

t0 = tic;
t_command = 0;
t = 0:Ts:duration;

Kp = 4;
Kd = 0.0375;
a_d = 10;

pos_buf = zeros(6, length(t));
pos = posFrom;
pos_buf(:,1) = pos;
pos_d = posTo*ones(1, length(t));

vel_buf = zeros(6, length(t));
vel = zeros(6,1);
vel_d = vel_buf;
vel_input = vel_buf;

disp('into the movement loop');

for j = 2:length(t)

    v_feed = Kp*(pos_d(:, j) - pos) + Kd*(vel_d(:, j) - vel);
    
%     if v_feed(i) > v_tol(i)
%         v_feed(i) = v_tol(i);
%         disp('Warning: velocity limit reached!!');
%     elseif v_feed(i) < -v_tol(i) 
%         v_feed(i) = -v_tol(i);
%         disp('Warning: velocity limit reached!!');
%     end
    
    t_init = tic;
    arm.setJointsSpeed(v_feed, a_d, 2*Ts);
    
    while toc(t_init) < Ts    
    end
    
    arm.update();
    
    pos = arm.getJointsPositions();
    vel = arm.getJointsSpeeds();
    
    pos_buf(:,j) = pos;
    vel_buf(:,j) = vel;
    vel_input(:,j) = v_feed;
end

disp('out of the movement loop');

bufPos{i} = pos_buf;
bufV{i} = vel_buf;

pause(1);

end

UR5.reset_arm(arm);
arm.fclose();

clear acc t_buf y_buf vel pos a_d v_d t t_command;
clear t0 y yd ydd i j;