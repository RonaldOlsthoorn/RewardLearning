function [ S_eval, Weights ] = evaluate_progress(S, S_eval, ro_par_eval, ...
                                        ro_par, sim_par, rm, i )

R = zeros(S.n_end, ro_par.reps);

for k=1:ro_par.reps
    R(:,k) = S.rollouts(k).R;
end                                    
                                    
global dcps

% perform one noiseless evaluation to get the cost
S_eval=run_rollouts(S_eval, ro_par_eval, sim_par, 1);

% compute all costs in batch from, as this is faster in matlab
S_eval = compute_reward( S_eval, ro_par_eval, rm );

% store the noise-less reward and the weights
Weights(i,:) = dcps(1).w';

% visualization: plot at the start and end of the updating
if mod(i,10)== 1,
    fprintf('%5d.Cost = %f \n',i,sum(S_eval.rollouts(1).R));
    print_progress(S, S_eval, ro_par, i)
end

end

