function R = reward_overshoot(S, ro_par)
% Implements a simple squared error cost function. 
% Struct D: Result of roll-outs.
                        
n = S.n_end;            % The duration of the complete simulation 
                        % (core trajectory + terminal simulation).
                        
delta_step = ro_par.goal - ro_par.start;

R = zeros(n,ro_par.reps);   % Reward container (not to be confused with control effort).
 
for k=1:ro_par.reps,
    
    if delta_step>0
        [opt_output, ~] = max(S.rollouts(k).q(1:n,1));
    else
        [opt_output, ~] = min(S.rollouts(k).q(1:n,1));
    end
        
    overshoot = opt_output/delta_step;
        
    % Cost during trajectory
    R(end,k) = -overshoot;
end