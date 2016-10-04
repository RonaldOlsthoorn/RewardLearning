class RewardPrimitiveSquaredError < RewardPrimitive

    methods

(S, ro_par)
% Implements a simple squared error cost function. 
% Struct S: Result of roll-outs.
% Struct ro_par: rollout parameters.
                        
n = S.n_end;            % The duration of the complete simulation 
                        % (core trajectory + terminal simulation).

R = zeros(n,ro_par.reps);   % Reward container (not to be confused with control effort).

% Create trajectory to track.
ref = S.ref.r_tool';
 
for k=1:ro_par.reps,
        
    % Cost during trajectory
    r  = -sum((S.rollouts(k).ef_positions(1:3,:)'-ref(:,1:3)).^2, 2);   
    R(:,k) = r;
end

