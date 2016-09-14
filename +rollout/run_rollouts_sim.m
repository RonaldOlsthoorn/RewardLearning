function S = run_rollouts_sim(S, dmp_par, forward_par, sim_par, iteration, n_ro)
% A dedicated function to run multiple roll-outs using the specifictions in ro_par. 
% noise_mult allows decreasing the noise with the number of roll-outs, which gives
% smoother converged performance (but it is not needed for convergence).

% S: struct containing the result of sampling
% ro_par: struct containing rollout parameters.
% sim_par: struct containing simulation parameters.
% n_ro: number of rollouts to perform.

import plant.*
import rollout.*

for k=1:n_ro,
   
    ro = Rollout();
    ro.iteration = iteration;
    ro.index = k;
    S.rollouts(k) = ro;    
end

S = gen_epsilon(S, forward_par, n_ro);

for k = 1:n_ro, % Run DMPs
    
    for j=1:dmp_par.n_dmps,
        
        [y, yd, ydd] = S.dmps(j).run(S.rollouts(k).dmp(j).eps(1,:)');
        S.rollouts(k).dmp(j).xd = [y, yd, ydd];    % desired state.
    end
end

for k=1:n_ro, % Run the robotic arm   
    
    q = [dmp_par.start(1);0;0];  
    
    for n=1:S.n_end,
        
        % integrate simulated 1 DoF robot arm with a lousy PID controller
        % based on DMP output -- essentially, this try realize
        % the DMP output, miserably failing at it.
        r = S.rollouts(k).dmp(1).xd(n,:)';
        
        [q_next] = f_closed_loop(q, r, sim_par);        
        q = q_next';
        
        S.rollouts(k).joint_positions(n,:) = q(1,1);    % store the state
        S.rollouts(k).joint_speeds(n,:) = q(2,1);    % store the state

    end
end