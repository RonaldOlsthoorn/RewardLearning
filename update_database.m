function rm = update_database(S, R, rm, reps)

for i = 1:reps
    
    new_rollouts(i).eps_theta = S.rollouts(i).dmp.theta_eps;
    new_rollouts(i).eps       = S.rollouts(i).dmp.eps;
    new_rollouts(i).R         = R(:,i);
    
end

if exist('rm.Database','var'),
    rm.Database = [rm.Database new_rollouts];
else
    rm.Database = new_rollouts;
end

