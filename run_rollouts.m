function D=run_rollouts(D,noise_mult)
% a dedicated function to run muultiple roll-outs using the specifictions in D. 
% noise_mult allows decreasing the noise with the number of roll-outs, which gives
% smoother converged performance (but it is not needed for convergence).

global n_dmps;
global control_method;
global Ts;
global par;

start = D.n_reuse + 1;  % take into account the reused roll-outs.
if (noise_mult == 1)    % indicates very first batch of rollouts.
    start = 1;       
end

D = gen_epsilon(D, start, noise_mult);

for k=start:D.reps, % Run DMPs
    
    % reset the DMP
    for j=1:n_dmps,
        dcp('reset_state',j,D.start(j));
        dcp('set_goal',j,D.goal(j),1);
        % dcp('set_scale',j,abs(D.goal(j)-D.start(j)));
    end
    
    % run the DMPs to create the desired trajectory
    for n=1:D.n_end,                    
        for j=1:n_dmps,                           
            [y,yd,ydd,b]=dcp('run',j,D.duration,Ts,0,0,1,1,D.rollouts(k).dmp(j).eps(n,:)');  
            D.rollouts(k).dmp(j).xd(n,:)   = [y,yd,ydd];% desired state.
            D.rollouts(k).dmp(j).bases(n,:) = b';       % bases. used for updates.
        end      
    end
    
end

for k=start:D.reps, % Run the robotic arm    
    q = [D.start(1);0;D.start(2);0];  
    
    for n=1:D.n_end,
        
        % integrate simulated 2 DoF robot arm with inverse dynamics control
        % based on DMP output -- essentially, this just perfectly realizes
        % the DMP output, but one could add noise to this equation to make
        % it more interesting.
        
        r = [D.rollouts(k).dmp(1).xd(n,:)';D.rollouts(k).dmp(2).xd(n,:)'];
        
        [q_next] = f_closed_loop(q,r, control_method, par);        
        q = q_next';
        
        D.rollouts(k).q(n,:)   = q';    % store the state

    end
end