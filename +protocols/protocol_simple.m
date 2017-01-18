function [ protocol ] = protocol_simple()

plant_par.type = 'UR5';
plant_par.sim = false;
plant_par.Ts = 0.01;

controller_par.type = 'controllerPID';
controller_par.Kp = 3;
controller_par.Ki = 0;
controller_par.Kd = 0.0375;

reference_par.start_tool=[-0.2619;-0.1091;0.3623;1.2088;-1.2107;-1.2104];
reference_par.goal_tool=[-0.4619;-0.0091;0.3623;1.2088;-1.2109;-1.2103];
reference_par.start_joint=[0;-2*pi/3;2*pi/3;0;pi/2;0];
reference_par.goal_joint=[-0.2672;-1.6281;1.7727;-0.1439;1.3053;0];
reference_par.use_ik=true;
reference_par.duration=8;
reference_par.Ts=0.01;
reference_par.trajectory='trajectory_robot';

agent_par.type = 'agent_PI2DRLegacy';
agent_par.noise_std = [0.1;0.1;0.1;0.1;0.1;0];
agent_par.annealer = 6/100;
agent_par.reps = 10;
agent_par.n_reuse = 5;

policy_par.dof = 6;
policy_par.type = 'rbf_ff';
policy_par.n_rbfs = 40;
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