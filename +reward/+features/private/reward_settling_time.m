function R = reward_settling_time(S, ro_par)
% Implements a settling time penalty function. 
% Struct S: Result of roll-outs.
% Struct ro_par: rollout parameters.
                        
n = S.n_end;            % The duration of the complete simulation 
                        % (core trajectory + terminal simulation).
                        
delta_step = ro_par.goal - ro_par.start;
rel_tol = 0.05;
abs_tol = rel_tol*delta_step;

R = zeros(n,ro_par.reps);   % Reward container (not to be confused with control effort).
 
for k=1:ro_par.reps,
    
    margin = abs(S.rollouts(k).q(:,1)- ro_par.goal);
    settling_index = length(S.rollouts(k).q(:,1))- ...
        find(flipud(margin)>=abs_tol,1)+1;
    
    % Cost during trajectory
    R(end,k) = -S.t(settling_index);
end