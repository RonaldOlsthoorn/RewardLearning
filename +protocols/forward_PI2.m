function [forward_rl_par] = forward_PI2()
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

forward_rl_par.forward_method = 'PI2';
forward_rl_par.std = [200;100;100;20;200;0];
forward_rl_par.annealer = 1/100;
forward_rl_par.reps = 10;
forward_rl_par.n_reuse = 5;
forward_rl_par.n_dmp_bf = 40;
end

