function [forward_rl_par] = agent_PI2()
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

forward_rl_par.type = 'agent_PI2';
forward_rl_par.noise_std = [0.1;0.1;0.1;0.1;0.1;0];
forward_rl_par.annealer = 6/100;
forward_rl_par.reps = 10;
forward_rl_par.n_reuse = 5;
forward_rl_par.n_dmp_bf = 40;
end