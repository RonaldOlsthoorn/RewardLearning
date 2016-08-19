clear; close all; clc;

% read the protocol file
p = read_protocol('test_protocol.txt');

% initializes a 1 DOF DMP -- this is dones as two independent DMPs as the
% Matlab DMPs currently do not support multi-DOF DMPs.
global n_dmps;
n_dmps = 1;

[ S, S_eval, dmp_par, forward_par, forward_par_eval, ...
    sim_par, rm ] = init(p);

% before we run the main loop, we need 1 demo to initialize the reward
% model
rm = run_first_demo(S, rm, forward_par, dmp_par, sim_par);

i = 1;

S = run_rollouts(S, dmp_par, forward_par, sim_par, i, forward_par.reps);
S = compute_reward(S, forward_par, rm);
    %rm = update_database(S, forward_par, rm, forward_par.reps);

dtheta = get_PI2_dtheta(S, forward_par);

dtheta_per_sample = get_PI2_update_per_sample(S, forward_par);

dtheta_per_sample = squeeze(dtheta_per_sample);

dtheta2 = sum(dtheta_per_sample, 1);