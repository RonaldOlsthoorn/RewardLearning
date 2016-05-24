function rm = update_database(S, ro_par, rm, reps)

new_rollouts.eps_theta  = zeros(S.n_end, ro_par.n_rfs);
new_rollouts.eps        = zeros(S.n_end, ro_par.n_rfs);
new_rollouts.outcomes   = zeros(S.n_end, rm.n_ff);
new_rollouts.R          = zeros(S.n_end, 1);

new_rollouts(1:reps) = new_rollouts;

for i = 1:reps
    
    new_rollouts(i).eps_theta = S.rollouts(i).dmp.theta_eps;
    new_rollouts(i).eps       = S.rollouts(i).dmp.eps;
    new_rollouts(i).outcomes  = S.rollouts(i).outcomes;
    new_rollouts(i).R         = S.rollouts(i).R;
    
end

if exist('rm.Database','var'),
    rm.Database = [rm.Database new_rollouts];
else
    rm.Database = new_rollouts;
end

