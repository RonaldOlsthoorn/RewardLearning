function [ R_eval, Weights ] = evaluate_progress(S, S_eval, D, R, ...
                                           ro_par_eval, ro_par, rm, i )

global dcps

% perform one noiseless evaluation to get the cost
S_eval=run_rollouts(S_eval, ro_par_eval);

% compute all costs in batch from, as this is faster in matlab
R_eval = compute_reward( S_eval, ro_par_eval, rm );

% store the noise-less reward and the weights
Weights(i,:) = dcps(1).w';

% visualization: plot at the start and end of the updating
if mod(i,10)== 1,
    fprintf('%5d.Cost = %f \n',i,sum(R_eval));
    print_progress(S, S_eval, D, R, R_eval, ro_par, i)
end

end

