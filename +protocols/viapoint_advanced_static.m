function [ protocol ] = viapoint_advanced_static()

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

reference_par.trajectory = '2dof_advanced'; 
reference_par.start_tool = [0;0.5];
reference_par.goal_tool = [0.5;0.3];
reference_par.start_joint = [pi/6;(2*pi/3)];
reference_par.goal_joint = [0.2203;0.6767];
reference_par.duration = 8;
reference_par.Ts = plant_par.Ts;

reference_par.viapoint_t = 300;
reference_par.viapoint = [0.3; 0.6];
reference_par.viaplane_t = [601, 800];
reference_par.dim = 'xy';
reference_par.level = [0.5;0.3];

agent_par.type = 'agent_PI2BB';
agent_par.noise_std = [100; 100];
agent_par.annealer = 0.95;
agent_par.reps = 10;
agent_par.n_reuse = 5;

policy_par.type = 'dmp_ref_ik';
policy_par.dof = 2;
policy_par.n_rbfs = 20;
policy_par.duration = 8;
policy_par.Ts =  plant_par.Ts;
policy_par.start = reference_par.start_tool;
policy_par.goal = reference_par.goal_tool;

env_par.dyn = false;
env_par.acquisition = 'epd';
env_par.expert = 'hard_coded_expert';
env_par.expert_std = 0;
env_par.tol = 0.1;

reward_model.type = 'viapoint_advanced_static';

protocol.plant_par = plant_par;
protocol.controller_par = controller_par;
protocol.reference_par = reference_par;
protocol.agent_par = agent_par;
protocol.policy_par = policy_par;
protocol.env_par = env_par;
protocol.reward_model_par = reward_model;

end