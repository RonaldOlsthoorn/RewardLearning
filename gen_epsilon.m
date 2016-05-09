function S = gen_epsilon(S, start, ro_par)
% Generates requested ammount of noise profiles and stores
% the noise values in the structure D.

global n_dmps;
global dcps;

for k=start:ro_par.reps,
    
    for j=1:n_dmps,
        std_eps = ro_par.std * ro_par.noise_mult;
        epsilon = std_eps*randn(ro_par.n_rfs,1)*ones(1,S.n_end);
        
        % store noise in D struct.
        S.rollouts(k).dmp(j).theta_eps = (dcps(j).w*ones(1,S.n_end)+epsilon)';
        S.rollouts(k).dmp(j).eps = epsilon';
    end
    
end