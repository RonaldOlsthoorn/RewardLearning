clear; close all; clc;
import dmp.*

arm = UR5.driver.URArm();
ip = '192.168.1.50';
arm.fopen(ip);

UR5.reset_arm(arm);
tolerance = 0.001;

Ts = 0.005;

pause(1);

arm.update();
posFrom = arm.getJointsPositions();
velFrom = arm.getJointsSpeeds();

v_feed = [0;0;0;0;0;0.1];

disp('into the movement loop');

t = 0:Ts:1;
v_joints = zeros(6, length(t));
a_d = 10;

for j = 2:length(t)
    
    t_init = tic;
        
    arm.setJointsSpeed(v_feed, a_d, 4*Ts);
    
    while toc(t_init) < Ts    
    end
    
    arm.update();
    
    v_joints(:,j) = arm.getJointsSpeeds();
end

UR5.gently_break(arm);

disp('out of the movement loop');

pause(1);

UR5.reset_arm(arm);
arm.fclose();

plot(t, v_joints(end,:));
