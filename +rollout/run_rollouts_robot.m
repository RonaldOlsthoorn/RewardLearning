function S = run_rollouts_robot(S, dmp_par, forward_par, ~, iteration, n_ro)
% A dedicated function to run multiple roll-outs using the specifictions in ro_par.
% noise_mult allows decreasing the noise with the number of roll-outs, which gives
% smoother converged performance (but it is not needed for convergence).
%
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

a = 10;

for i=1:n_ro,
    
    ro = Rollout();
    ro.iteration = iteration;
    ro.index = i;
    ro.joint_positions = zeros(n_dmps, S.n_end);
    ro.joint_speeds = zeros(n_dmps, S.n_end);
    ro.ef_positions = zeros(n_dmps, S.n_end);
    ro.ef_speeds = zeros(n_dmps, S.n_end);
    
    S.rollouts(i) = ro;
end

S = gen_epsilon(S, forward_par, n_ro);

for i = 1:n_ro, % Run DMPs
    
    r = zeros(n_dmps, S.n_end);
    rd = zeros(n_dmps, S.n_end);
    
    
    for k=1:n_dmps,
        
        [y, yd, ydd] = S.dmps(k).run(S.rollouts(i).dmp(k).eps(1, :)');
        S.rollouts(i).dmp(k).xd = [y, yd, ydd]; % desired state.
        r(k,:) = y';
        rd(k,:) = yd';
    end
    
    UR5.reset_arm(arm);
    
    arm.update();
    
    p = arm.getJointsPositions();
    v = arm.getJointsSpeeds();
    
    S.rollouts(i).joint_positions(:,1) = p;
    S.rollouts(i).joint_speeds(:,1) = v;
    S.rollouts(i).ef_positions(:,1) = arm.getToolPositions();
    S.rollouts(i).ef_speeds(:,1) = arm.getToolSpeeds();
    S.rollouts(i).time = zeros(1,S.n_end);
        
    pause(1);
    
    t0 = tic;
    
    for j=1:S.n_end,
        
        t = tic;
        v_feed = UR5.externalPD(r(:,j), rd(:,j), p, v);
        v_feed = UR5.saturation(v_feed);
        arm.setJointsSpeed(v_feed, a, 2*dmp_par.Ts);
        
        while toc(t) < dmp_par.Ts
        end
        
        arm.update();
        p = arm.getJointsPositions();
        v = arm.getJointsSpeeds();
        
        S.rollouts(i).joint_positions(:,j) = p;    % store the state
        S.rollouts(i).joint_speeds(:,j) = v;   % store the state
        S.rollouts(i).ef_positions(:,j) = arm.getToolPositions();    % store the state
        S.rollouts(i).ef_speeds(:,j) = arm.getToolSpeeds();   % store the state 
        S.rollouts(i).time(j) = toc(t0);
    end
end

pause(1);
UR5.reset_arm(arm);
pause(1);

%% close
arm.fclose();