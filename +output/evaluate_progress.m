function [S_eval, Weights] = evaluate_progress(S, S_eval, arm, dmp_par, ...
                                        forward_par_eval, sim_par, rm, i )
                                    
% Evaluate and print the progress of the algorithm so far.                                    
r = zeros(S.n_end, forward_par_eval.reps);

for k=1:forward_par_eval.reps
    r(:,k) = S.rollouts(k).r';
end                                                                      

S_eval.dmps = S.dmps;

% perform one noiseless evaluation to get the cost
S_eval = S_eval.run_rollouts(S_eval, arm, dmp_par, forward_par_eval, sim_par, i, 1);

% compute all costs in batch from, as this is faster in matlab
S_eval = reward.compute_reward_static(S_eval, forward_par_eval, rm );

% store the noise-less reward and the weights
Weights(i,:) = S.dmps(1).w';

fprintf('%5d.Cost = %f \n',i,S_eval.rollouts(1).R(1));

% visualization: plot at the start and end of the updating
% if mod(i,10)== 1,
    
    output.print_progress(S, S_eval, forward_par_eval, i);   
% end

end

