import dmp.dcp;
import dmp.DMP;
import refs.ref_trajectory;
import init.*;
import rollout.Rollout;

clear; close all; clc;

n_dmps = 1;

dmp_par.n_dmp_bf = 40;
dmp_par.duration = 8;
dmp_par.Ts = 0.01;
dmp_par.goal = 2;
dmp_par.start = 0;
S.ref = ref_trajectory(dmp_par);
S.t = 0:dmp_par.Ts:(dmp_par.duration-dmp_par.Ts);
S.n_end = length(S.t);

for i=1:n_dmps,                     % initialize DMPs
    dcp('clear', i);
    dcp('init', i, dmp_par.n_dmp_bf, sprintf('pi2_dmp_%d', i), 0);
    
    % use the in-built function to initialize the dcp with reference trajectory
    if ~strcmp('none', S.ref)        
        dcp('Batch_Fit', i, dmp_par.duration, dmp_par.Ts, S.ref.r(i,:)', S.ref.r_d(i,:)', S.ref.r_dd(i,:)');        
    end
    
    dcp('reset_state', i, dmp_par.start(i));
    dcp('set_goal', i, dmp_par.goal(i), 1);
end

S.psi       = dcp('run_psi', 1, dmp_par.duration, dmp_par.Ts); % Obtain basis functions
S.time_weight = get_time_weight(S, dmp_par); 

S_eval.psi  = S.psi;

dcp('reset_state', 1, dmp_par.start(1));
dcp('set_goal', 1, dmp_par.goal(1),1);

dmp = DMP(1, dmp_par);
dmp.batch_fit(S.ref.r(i,:)', S.ref.r_d(i,:)', S.ref.r_dd(i,:)');


%%

% reset the DMP
for j=1:n_dmps,
    dcp('reset_state', j, dmp_par.start(j));
    dcp('set_goal', j, dmp_par.goal(j),1);
end

rollout1 = Rollout();

eps = 1000*randn(dmp_par.n_dmp_bf,1);

%eps = zeros(dmp_par.n_dmp_bf, 1);

% run the DMPs to create the desired trajectory
for n=1:S.n_end,
    for j=1:n_dmps,
        [y, yd, ydd, b]=dcp('run', j, dmp_par.duration, dmp_par.Ts, ...
            0, 0, 1, 1, eps);
        
        rollout1.dmp(j).xd(n,:) = [y, yd, ydd];    % desired state.
        rollout1.dmp(j).bases(n,:) = b';           % bases. used for updates.
    end
end

[y, yd, ydd] = dmp.run(eps);

figure
hold on
plot(rollout1.dmp(1).xd(:,1));
plot(y);

figure
hold on
plot(rollout1.dmp(1).xd(:,2));
plot(yd);

figure
hold on
plot(rollout1.dmp(1).xd(:,3));
plot(ydd);


% figure
% subplot(1,2,1)
% bar(dcps(1).w);
% ylabel('theta');
% axis('tight');
% subplot(1,2,2)
% bar(dmp.w);
% ylabel('theta');
% axis('tight');
% 
