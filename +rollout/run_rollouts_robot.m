function S = run_rollouts_robot(S, dmp_par, forward_par, ~, iteration, n_ro)
% A dedicated function to run multiple roll-outs using the specifictions in ro_par.
% noise_mult allows decreasing the noise with the number of roll-outs, which gives
% smoother converged performance (but it is not needed for convergence).

% S: struct containing the result of sampling
% ro_par: struct containing rollout parameters.
% sim_par: struct containing simulation parameters.
% n_ro: number of rollouts to perform.

import UR5.*
import dmp.dcp
import rollout.*

n_dmps = dmp_par.n_dmps;

arm = UR5.driver.URArm();
ip = '192.168.1.50';
arm.fopen(ip);

for i=1:n_ro,
    
    ro = Rollout();
    ro.iteration = iteration;
    ro.index = i;
    S.rollouts(i) = ro;
end

S = gen_epsilon(S, forward_par, n_ro);

for i = 1:n_ro, % Run DMPs
    
    ur5.reset_arm();  
    q = arm.getJointPositions; % = update and read;
    
    for j=1:S.n_end,
        
        r = zeros(n_dmps, 3);
        
        for k=1:n_dmps,
            
            [y, yd, ydd] = S.dmps(k).run(S.rollouts(i).dmp(k).eps(1, :)');
            S.rollouts(i).dmp(k).xd(j, :) = [y, yd, ydd]; % desired state.
            r(k, :) = [r; [y, yd, ydd]];
        end    
        
        r = S.rollouts(i).dmp(1).xd(j, :)';
        
        
        
        v_feed = Kp*(r - q) + Kd*(rd - qd);

        
        q = arm.getJointsPositions();
        
        S.rollouts(i).q(j,:) = q;    % store the state
        
    end
end

%% close
arm.fclose();