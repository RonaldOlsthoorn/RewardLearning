function rm = run_first_demo(S, rm, ro_par, sim_par)
% runs first roll-outs en queries the expert for its rating
% this is necessary for the initialization of the reward model.

S = run_rollouts(S, ro_par, sim_par, ro_par.reps);

outcomes =  compute_outcomes(S, ro_par, rm );
sum_out  = rot90(rot90(cumsum(rot90(rot90(outcomes)))));

zero_sum_out = zeros(ro_par.reps,rm.n_ff);
seg.sum_out = zero_sum_out;
seg.R_expert = zeros(ro_par.reps,1);

rm.seg(1:rm.n_segments) = seg;

for k = 1:ro_par.reps
    
    for s = 1:rm.n_segments
        
        rm.seg(s).sum_out(k,:)  = squeeze(sum_out(rm.seg_start(s),k,:));
        rm.seg(s).R_expert(k) = query_expert( rm.seg(s).sum_out(k,:) , rm.rating_noise );
    end
    
end

for s = 1:rm.n_segments
    
    rm.seg(s).hyp.cov = [10*ones(rm.n_ff,1); 10];
    %rm.seg(s).hyp.mean = [ones(rm.n_ff,1); 1];
    rm.seg(s).hyp.mean = [];
    rm.seg(s).hyp.lik = log(0.1);
    
    rm.seg(s).hyp = minimize(rm.seg(s).hyp, @gp, -100, @infExact, ...
        rm.meanfunc, rm.covfunc, rm.likfunc, ...
        rm.seg(s).sum_out, rm.seg(s).R_expert);
    
end

