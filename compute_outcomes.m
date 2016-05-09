function [ outcomes ] = compute_outcomes( S, ro_par )
% Computes the outcomes (feature functions of the reward model) of the 
% reward model.

outcomes(:,:,1) = reward_err2(S, ro_par );
outcomes(:,:,2) = reward_abs(S, ro_par );
outcomes(:,:,3) = reward_overshoot(S, ro_par );
outcomes(:,:,4) = reward_settling_time(S, ro_par );

end

