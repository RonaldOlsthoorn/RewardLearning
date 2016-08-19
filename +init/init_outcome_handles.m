function [ handles ] = init_outcome_handles( rm )
% Initialize a set of handles to outcome functions. Outcome functions are
% basically feature functions of the reward model. 

    handles = cell(rm.n_ff);
    handles{1} = @(S, ro_par)reward_err2(S, ro_par);
    handles{2} = @(S, ro_par)reward_abs(S, ro_par);
%     handles{3} = @(S, ro_par)reward_overshoot(S, ro_par);
%     handles{4} = @(S, ro_par)reward_settling_time(S, ro_par);
    
end
