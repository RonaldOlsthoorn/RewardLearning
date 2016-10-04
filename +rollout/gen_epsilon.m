function S = gen_epsilon(S, ro_par, n_ro)
% Generates requested ammount of noise profiles and stores
% the noise values in the structure S.

for k=1:n_ro,   
    for j=1:length(S.dmps),
        std_eps = ro_par.std(j) * ro_par.noise_mult;
        epsilon = std_eps*randn(ro_par.n_dmp_bf,1)*ones(1,S.n_end);
        
        % store noise in S struct.
        S.rollouts(k).dmp(j).theta_eps = (S.dmps(j).w*ones(1,S.n_end)+epsilon)';
        S.rollouts(k).dmp(j).eps = epsilon';
    end
end