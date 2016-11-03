function [ protocol ] = PI2DR()

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

controller_par.type = 'controllerInvKin';
controller_par.Kp = 3;
controller_par.Ki = 0;
controller_par.Kd = 0.0375;

reference_par.start_tool=[0;0.5];
reference_par.goal_tool=[0.8;0.5];
reference_par.start_joint=[pi/6;(2*pi/3)];
reference_par.goal_joint=[0.2203;0.6767];
reference_par.use_ik=true;
reference_par.duration=8;
reference_par.Ts=0.01;
reference_par.trajectory='2dof';    

agent_par.type = 'agent_PI2DR';
agent_par.noise_std = [0.01;0.01];
agent_par.annealer = 0.95;
agent_par.reps = 10;
agent_par.n_reuse = 5;

policy_par.dof = 2;
policy_par.type = 'rbf_ref';
policy_par.n_rbfs = 20;
policy_par.duration = 8;
policy_par.Ts = 0.01;

reward_model_par.type = 'reward_model_static_lin';
reward_model_par.feature_block = 'SimpleFeatureBlock';

protocol.plant_par = plant_par;
protocol.controller_par = controller_par;
protocol.reference_par = reference_par;
protocol.agent_par = agent_par;
protocol.policy_par = policy_par;
protocol.reward_model_par = reward_model_par;
end

