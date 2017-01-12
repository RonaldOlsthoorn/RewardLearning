function [ protocol ] = viapoint_UR5_static()

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
reference_par.use_ik=false;
reference_par.duration=8;
reference_par.Ts=0.01;
reference_par.trajectory='robot-via';    

reference_par.viapoint_t = [300];
reference_par.viapoint = [-0.3;-0.08;0.3623;1.2088;-1.2107;-1.2104];

agent_par.type = 'agent_PI2BB';
agent_par.noise_std = [0.1;0.1;0.1;0.1;0.1;0];
agent_par.annealer = 0.95;
%agent_par.annealer = 6/100;
agent_par.reps = 10;
agent_par.n_reuse = 5;

policy_par.type = 'UR5_dmp_ref';
policy_par.dof = 3;
policy_par.n_rbfs = 20;
policy_par.duration = 8;
policy_par.Ts =  plant_par.Ts;
policy_par.start = reference_par.start_tool;
policy_par.goal = reference_par.goal_tool;
policy_par.orientation = reference_par.start_tool(4:6);

env_par.dyn = false;
env_par.acquisition = 'epd';
env_par.expert = 'hard_coded_expert';
env_par.expert_std = 1e-3;
env_par.tol = 0.1;

reward_model.type = 'reward_model_UR5_static_vp';

protocol.plant_par = plant_par;
protocol.controller_par = controller_par;
protocol.reference_par = reference_par;
protocol.agent_par = agent_par;
protocol.policy_par = policy_par;
protocol.env_par = env_par;
protocol.reward_model_par = reward_model;

end