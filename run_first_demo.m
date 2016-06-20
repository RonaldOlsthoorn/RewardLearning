function rm = run_first_demo(S, rm, ro_par, sim_par)
% runs first roll-outs en queries the expert for its rating
% this is necessary for the initialization of the reward model.

S = run_rollouts(S, ro_par, sim_par, ro_par.reps);

outcomes =  compute_outcomes( S, rm, ro_par );
sum_out  = rot90(rot90(cumsum(rot90(rot90(outcomes)))));

x = zeros(ro_par.reps, rm.n_ff);
y = zeros(ro_par.reps, 1);

for k = 1:ro_par.reps
    
    rm.D(k).outcomes = squeeze(outcomes(:,k,:));
    rm.D(k).sum_out  = squeeze(sum_out(:,k,:));
    
    R_expert = query_expert( rm.D(k).sum_out(1,:) , rm.rating_noise );    
    
    rm.D(k).R_expert = R_expert;
    
    x(k,:)  = rm.D(k).sum_out(1,:);
    y(k)    = rm.D(k).R_expert;
    
end

rm.hyp = minimize(rm.hyp, @gp, -100, @infExact, rm.meanfunc, rm.covfunc, rm.likfunc, x, y);
