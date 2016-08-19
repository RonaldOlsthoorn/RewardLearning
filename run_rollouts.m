function S = run_rollouts(S, dmp_par, forward_par, sim_par, iteration, n_ro)
% A dedicated function to run muultiple roll-outs using the specifictions in ro_par. 
% noise_mult allows decreasing the noise with the number of roll-outs, which gives
% smoother converged performance (but it is not needed for convergence).

% S: struct containing the result of sampling
% ro_par: struct containing rollout parameters.
% sim_par: struct containing simulation parameters.
% n_ro: number of rollouts to perform.

import plant.*
global n_dmps;

for k=1:n_ro,
    
    ro = roll_out(iteration, k);
    S.rollouts(k) = ro;
end


S = gen_epsilon(S, forward_par, n_ro);

for k = 1:n_ro, % Run DMPs
    
    % reset the DMP
    for j=1:n_dmps,
        dcp('reset_state', j, dmp_par.start(j));
        dcp('set_goal', j, dmp_par.goal(j),1);
    end
    
    % run the DMPs to create the desired trajectory
    for n=1:S.n_end,                    
        for j=1:n_dmps,                           
            [y, yd, ydd, b]=dcp('run', j, dmp_par.duration, dmp_par.Ts, ...
                0, 0, 1, 1, S.rollouts(k).dmp(j).eps(n,:)');  
            
            S.rollouts(k).dmp(j).xd(n,:) = [y, yd, ydd];    % desired state.
            S.rollouts(k).dmp(j).bases(n,:) = b';           % bases. used for updates.
        end      
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
        
        S.rollouts(k).q(n,:) = q';    % store the state

    end
end