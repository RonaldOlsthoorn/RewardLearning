clear; close all; clc;

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
reference_par.Ts= plant_par.Ts;
reference_par.trajectory='2dof';    

agent_par.type = 'agent_PI2BB';
agent_par.noise_std = [0.01;0.01];
agent_par.annealer = 0.95;
agent_par.reps = 10;
agent_par.n_reuse = 5;

policy_par.dof = 2;
policy_par.type = 'rbf_ref';
policy_par.n_rbfs = 20;
policy_par.duration = 8;
policy_par.Ts =  plant_par.Ts;

env_par.dyn = true;
env_par.acquisition = 'epd';
env_par.expert = 'hard_coded_expert';
env_par.tol = 0.1;

reward_model.type = 'reward_model_gp';

hyp.cov = [2;10];
hyp.mean = [1;0];
hyp.lik = log(0.01);

gp_par.likfunc = @likGauss;
gp_par.meanfunc = {@meanSum, {@meanLinear, @meanConst}};
gp_par.covfunc = @covSEard;
gp_par.hyp = hyp;

reward_model.gp_par = gp_par;

p.plant_par = plant_par;
p.controller_par = controller_par;
p.reference_par = reference_par;
p.agent_par = agent_par;
p.policy_par = policy_par;
p.env_par = env_par;
p.reward_model_par = reward_model;

%%

import plant.Plant;
import environment.Environment;

reference = init.init_reference(p.reference_par);
plant = init.init_plant(p.plant_par, p.controller_par);
plant.set_init_state(reference.r_joints(:,1));

policy = init.init_policy(p.policy_par, reference);
agent = init.init_agent(p.agent_par, policy);

reward_model = init.init_reward_model(p.reward_model_par,...
                reference);

batch_trajectory = agent.create_batch_trajectories(4);
batch_rollouts = plant.batch_run(batch_trajectory);

for i = 1:batch_rollouts.size
    
    rollout = reward_model.add_outcomes(batch_rollouts.get_rollout(i));
    rollout.R_expert = sum(rollout.outcomes);
    batch_rollouts.update_rollout(rollout);
end

reward_model.add_batch_demonstrations(batch_rollouts);
reward_model.gp.print();
reward_model.gp.minimize();
reward_model.gp.print();
