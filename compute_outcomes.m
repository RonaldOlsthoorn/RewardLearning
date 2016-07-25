function [ outcomes ] = compute_outcomes( S, ro_par, rm )
% Computes the outcomes (feature functions of the reward model) of the 
% reward model.
% S: struct containing all the samples of this iteration
% ro_par: struct containing roll-out parameters
% rm: struct containing the reward model

outcomes = zeros(S.n_end, ro_par.reps, rm.n_ff);

for j=1:length(rm.outcome_handles)
    outcomes(:,:,j) = rm.outcome_handles{j}(S, ro_par);  
end

end


