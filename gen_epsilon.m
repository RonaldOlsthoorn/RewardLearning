function D = gen_epsilon(D, start, noise_mult)
% Generates requested ammount of noise profiles and stores 
% the noise values in the structure D.

global n_dmps;
global n_rfs;
global dcps;

for k=start:D.reps,
    
    for j=1:n_dmps,
    std_eps = D.std * noise_mult;
    epsilon = std_eps*randn(n_rfs,1)*ones(1,D.n_end);
    
    % store noise in D struct.
    D.rollouts(k).dmp(j).theta_eps = (dcps(j).w*ones(1,D.n_end)+epsilon)';
    D.rollouts(k).dmp(j).eps = epsilon';
    end
    
end