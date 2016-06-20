function [ outcomes ] = compute_outcomes( S, rm, ro_par )
% Computes the outcomes (feature functions of the reward model) of the 
% reward model.

outcomes = zeros(S.n_end, ro_par.reps, rm.n_ff);

for j=1:length(rm.outcome_handles)
    outcomes(:,:,j) = rm.outcome_handles{j}(S, rm, ro_par);  
end

end


