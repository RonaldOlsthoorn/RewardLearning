function R = reward_abs(S, ro_par)
% Implements a simple absolute error cost function. 
% Struct S: Result of roll-outs.
% Struct ro_par: rollout parameters
                        
n = S.n_end;            % The duration of the complete simulation 
                        % (core trajectory + terminal simulation).

R = zeros(n, ro_par.reps);   % Reward container (not to be confused with control effort).

% Create trajectory to track.
ref = S.ref.r_tool';
 
for k=1:ro_par.reps,
        
    % Cost during trajectory
    r  = -sum(abs(S.rollouts(k).ef_positions(1:3,:)'-ref(1:n,1:3)), 2);   
    R(:,k) = r;
end

