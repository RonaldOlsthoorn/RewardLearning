function [ handles ] = init_outcome_handles( rm )

    handles = cell(rm.n_ff);
    
    for i=1:rm.n_reward_bf
        handles{i} = @(S, rm, ro_par)weighted_error(S, rm, ro_par, i);
    end
    
    for i=1:rm.n_reward_bf
        handles{rm.n_reward_bf+i} = @(S, rm, ro_par)weighted_abs(S, rm, ro_par, i);
    end   
    
    handles{2*rm.n_reward_bf+1} = @(S, rm, ro_par)reward_overshoot(S, ro_par);
    handles{2*rm.n_reward_bf+2} = @(S, rm, ro_par)reward_settling_time(S, ro_par);
    
end

function [weighted_error] = weighted_error(S, rm, ro_par, i)

    outcome = reward_err2(S, ro_par);
    weighted_error = (ones(ro_par.reps, 1)*rm.activation(:,i)')'.*outcome;
    
end

function [weighted_error] = weighted_abs(S, rm, ro_par, i)

    outcome = reward_abs(S, ro_par);
    weighted_error = (ones(ro_par.reps, 1)*rm.activation(:,i)')'.*outcome;
    
end
