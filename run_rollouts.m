function S=run_rollouts(S, ro_par)
% a dedicated function to run muultiple roll-outs using the specifictions in D. 
% noise_mult allows decreasing the noise with the number of roll-outs, which gives
% smoother converged performance (but it is not needed for convergence).

global n_dmps;

start = ro_par.n_reuse + 1;  % take into account the reused roll-outs.
if (ro_par.noise_mult == 1)    % indicates very first batch of rollouts.
    start = 1;       
end

S = gen_epsilon(S, start, ro_par);

for k=start:ro_par.reps, % Run DMPs
    
    % reset the DMP
    for j=1:n_dmps,
        dcp('reset_state', j, ro_par.start(j));
        dcp('set_goal', j, ro_par.goal(j),1);
    end
    
    % run the DMPs to create the desired trajectory
    for n=1:S.n_end,                    
        for j=1:n_dmps,                           
            [y, yd, ydd, b]=dcp('run', j, ro_par.duration, ro_par.Ts, ...
                0, 0, 1, 1, S.rollouts(k).dmp(j).eps(n,:)');  
            
            S.rollouts(k).dmp(j).xd(n,:) = [y, yd, ydd];    % desired state.
            S.rollouts(k).dmp(j).bases(n,:) = b';           % bases. used for updates.
        end      
    end
    
end

for k=start:ro_par.reps, % Run the robotic arm    
    q = [ro_par.start(1);0;0];  
    
    for n=1:S.n_end,
        
        % integrate simulated 2 DoF robot arm with inverse dynamics control
        % based on DMP output -- essentially, this just perfectly realizes
        % the DMP output, but one could add noise to this equation to make
        % it more interesting.
        
        r = S.rollouts(k).dmp(1).xd(n,:)';
        
        [q_next] = f_closed_loop(q, r, ro_par);        
        q = q_next';
        
        S.rollouts(k).q(n,:) = q';    % store the state

    end
end