import UR5.*
import rollout.*

clear; close all; clc;

i=1;
iteration = 1;
n_dmps = 6;

p = init.read_protocol('+protocols/protocol_robot.txt');
% Initializes a 1 DOF DMP -- this is dones as two independent DMPs as the
% Matlab DMPs currently do not support multi-DOF DMPs.

[S, S_eval, dmp_par, forward_par, forward_par_eval, ...
    sim_par, rm] = init.init(p);

model_UR5 = ik.create_model_UR5();

q = zeros(6, length(S.ref.r_tool(1,:)));
q(:, 1) = model_UR5.ikine(transl(S.ref.r_tool(:,1)), dmp_par.start_joint);

for i = 2:length(S.ref.r_tool(1,:))
    
    T = transl(S.ref.r_tool(:,i));
    qi = model_UR5.ikine(T, q(:,i-1));
    q(:, i)= qi';
end

i=1;

qd = [zeros(6, 1) diff(S.ref.r_joint, 1, 2)/dmp_par.Ts];

arm = UR5.driver.URArm();
ip = '192.168.1.50';
arm.fopen(ip);

a = 10;

ro = Rollout();
ro.iteration = iteration;
ro.index = i;
ro.joint_positions = zeros(n_dmps, S.n_end);
ro.joint_speeds = zeros(n_dmps, S.n_end);
ro.ef_positions = zeros(n_dmps, S.n_end);
ro.ef_speeds = zeros(n_dmps, S.n_end);

S.rollouts(i) = ro;

r = q;
rd = qd;

UR5.reset_arm(arm);

arm.update();

p = arm.getJointsPositions();
v = arm.getJointsSpeeds();

S.rollouts(i).joint_positions(:,1) = p;
S.rollouts(i).joint_speeds(:,1) = v;
S.rollouts(i).ef_positions(:,1) = arm.getToolPositions();
S.rollouts(i).ef_speeds(:,1) = arm.getToolSpeeds();
S.rollouts(i).time = zeros(1,S.n_end);

pause(1);

display(strcat('Rollout number:', ' ', num2str(i)));

t0 = tic;

for j=1:S.n_end,
    
    t = tic;
    v_feed = UR5.externalPD(r(:,j), rd(:,j), p, v);
    v_feed = UR5.saturation(v_feed);
    arm.setJointsSpeed(v_feed, a, 2*dmp_par.Ts);
    
    while toc(t) < dmp_par.Ts
    end
    
    arm.update();
    p = arm.getJointsPositions();
    v = arm.getJointsSpeeds();
    
    S.rollouts(i).joint_positions(:,j) = p;    % store the state
    S.rollouts(i).joint_speeds(:,j) = v;   % store the state
    S.rollouts(i).ef_positions(:,j) = arm.getToolPositions();    % store the state
    S.rollouts(i).ef_speeds(:,j) = arm.getToolSpeeds();   % store the state
    S.rollouts(i).time(j) = toc(t0);
end

pause(1);
UR5.reset_arm(arm);
pause(1);
