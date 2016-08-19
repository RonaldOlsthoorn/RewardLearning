function [forward_par] = update_PI2(S, forward_par)

global n_dmps;
global dcps;

dtheta_per_sample = get_PI2_update_per_sample( S, forward_par );
dtheta = sum(dtheta_per_sample, 2);

% and update the parameters by directly accessing the dcps data structure
for i=1:n_dmps,
    
    dcps(i).w = dcps(i).w + dtheta(i,:)';
    
end

% run learning roll-outs with a noise annealing multiplier
forward_par.noise_mult = forward_par.noise_mult - i*forward_par.annealer;
forward_par.noise_mult = max([0.1 forward_par.noise_mult]);