function R = reward_abs(S, ro_par)
% Implements a simple absolute error cost function. 
% Struct D: Result of roll-outs.
                        
n = S.n_end;            % The duration of the complete simulation 
                        % (core trajectory + terminal simulation).

R = zeros(n, ro_par.reps);   % Reward container (not to be confused with control effort).

% Create trajectory to track.
ref = S.ref.r';
 
for k=1:ro_par.reps,
        
    % Cost during trajectory
    r  = -abs(S.rollouts(k).q(1:n,1)-ref(1:n,1));   
    R(:,k) = r;
end

