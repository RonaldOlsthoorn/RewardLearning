function [ S, S_eval ] = init_dmps( S, S_eval, dmp_par )

global n_dmps;

for i=1:n_dmps,                     % initialize DMPs
    dcp('clear', i);
    dcp('init', i, dmp_par.n_dmp_bf, sprintf('pi2_dmp_%d', i), 0);
    
    % use the in-built function to initialize the dcp with reference trajectory
    if ~strcmp('none', S.ref)        
        dcp('Batch_Fit', i, dmp_par.duration, dmp_par.Ts, S.ref.r(i,:)', S.ref.r_d(i,:)', S.ref.r_dd(i,:)');        
    end
    
    dcp('reset_state', i, dmp_par.start(i));
    dcp('set_goal', i, dmp_par.goal(i), 1);
end

S.psi       = dcp('run_psi',1, dmp_par.duration, dmp_par.Ts); % Obtain basis functions
S.time_weight = get_time_weight(S, dmp_par); 

S_eval.psi  = S.psi;

dcp('reset_state', 1, dmp_par.start(1));
dcp('set_goal', 1, dmp_par.goal(1),1);

end

