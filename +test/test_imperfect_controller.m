clear; clc; close all;

plant_par.type = '2-dof';
plant_par.sim = true;
plant_par.Ts = 0.01;

par.l1  = 0.5;          % Length link 1
par.l2  = 0.5;          % Length link 2
par.r1  = 0.5*par.l1;   % Distance CoG link 1
par.r2  = 0.5*par.l2;   % Distance CoG link 2
par.m1  = 0.5;          % Mass link 1
par.m2  = 0.5;          % Mass link 2
par.Iz1 = 0.01;         % Inertia link 1
par.Iz2 = 0.01;         % Inertia link 2
par.b1  = 3e-5;         % Viscuous dampink link 1
par.b2  = 3e-5;         % Viscuous dampink link 2
par.g   = 9.81;         % Gravity constant

plant_par.par = par;

s = plant.System2DOF(plant_par);
c = controller.ControllerImperfect();
p = plant.Plant2DOF(s, c);

p.set_init_state([0;0]);

trajectory = rollout.Rollout();
trajectory.policy.dof(1).xd = [0.*ones(1, 800); zeros(2, 800)];
trajectory.policy.dof(2).xd = [0.5.*ones(1, 800); zeros(2, 800)];
trajectory.time = 0:0.01:(8-0.01);

rollout1 = p.run(trajectory);

figure
plot(rollout1.time, rollout1.control_input(1,:));
x = [ rollout1.joint_positions(1,:);zeros(1,800); rollout1.joint_positions(2,:);zeros(1,800)];
body_animate(trajectory.time, x ,par);

%p.print_rollout(rollout1)