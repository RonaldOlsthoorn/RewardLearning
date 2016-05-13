function print_progress(S, S_eval, D, R, R_total, ro_par, figID)
% Plots the intermediate results of the running PI2 algorithm
% D: struct containing the roll-outs (noise included)
% D_eval: struct containing the noise-less roll-outs
% figID: ID (number) used as figure ID


for i=1:ro_par.reps
    legendInfo{i} = sprintf('rep_%d',i);
end

t = S_eval.t;

% figure(double(figID));
% set(double(figID), 'units','normalized','outerposition',[0 0 1 1]);
% clf;
%
% % plot the position trajectory for each dmp
% for j=1:n_dmps;
%
%     % dmp position
%     subplot(3,2,j);
%     hold on;
%     for i = 1:D.reps
%         plot(t,D.rollouts(i).q(:,j*2-1));
%     end
%     hold off;
%     xlabel('time [s]');
%     ylabel(sprintf('x_%d',j));
%     legend(legendInfo);
% end
%
% % plot the position trajectory for each dmp
% for j=1:n_dmps;
%
%     % dmp position
%     subplot(3,2,j+2);
%     hold on;
%     plot(t,D_eval.rollouts(1).q(:,j*2-1));
%     hold off;
%     xlabel('time [s]');
%     ylabel(sprintf('x_%d',j));
%
% end
%
% X = zeros(D.reps, D.n_end);
% Y = zeros(D.reps, D.n_end);
%
% % calculate the end-effector trajectories for each roll-out
% for k = 1:D.reps
%
%     q = [D.rollouts(k).q(:,1)'
%         zeros(1,D.n_end)
%         D.rollouts(k).q(:,3)'
%         zeros(1,D.n_end)];
%
%     [x_end] = forward_kinematics(q, par);
%     X(k,:) = x_end(1,:);
%     Y(k,:) = x_end(3,:);
% end
%
% % plot the end-effector trajectories
% subplot(3,2,5);
% hold on;
% plot(X', Y');
% plot(D_eval.ref.r(1,:),D_eval.ref.r(2,:));
% hold off;
% xlabel('x');
% ylabel('y');
% legend(legendInfo);
%
% % calculate the noise-less end-effector trajectory
% qq = [D_eval.rollouts(1).q(:,1)'
%     zeros(1,D_eval.n_end)
%     D_eval.rollouts(1).q(:,3)'
%     zeros(1,D_eval.n_end)];
%
% [x_end] = forward_kinematics(qq, par);
%
% % plot the noise-less end-effector trajectory
% subplot(3,2,6);
% hold on;
% plot(x_end(1,:), x_end(3,:));
% plot(D_eval.ref.r(1,:),D_eval.ref.r(2,:));
% hold off;
% xlabel('x');
% ylabel('y');

% figure(double(figID)+1);
% set(double(figID)+1, 'units','normalized','outerposition',[0 0 1 1]);
% clf;
%
% for j = 1:n_dmps
%
%     subplot(3,2,j);
%     bar(dcps(j).w);
%     ylabel('theta');
%     axis('tight');
%     title('Weights');
% end
%
% subplot(3,2,3);
% plot(t,R);
% xlabel('time [s]');
% ylabel('Cost');
% legend(legendInfo);
%
% subplot(3,2,4);
% plot(t,R_eval);
% xlabel('time [s]');
% ylabel('Cost');
%
% S = rot90(rot90(cumsum(rot90(rot90(R)))));
%
% subplot(3,2,5);
% plot(t,S);
% ylabel(sprintf('R=sum(r)'));
% legend(legendInfo);
%
% % the eponentiated and rescaled cumulative reward (the same for all DMPs)
% maxS = max(S,[],2);
% minS = min(S,[],2);
%
% h = 10;
%
% expS = exp(-h*(S - minS*ones(1,D.reps))./((maxS-minS)*ones(1,D.reps)));
% subplot(3,2,6);
% plot(t,expS);
% ylabel(sprintf('scaled exp(R)'));
% legend(legendInfo);

yy = zeros(S.n_end , ro_par.reps);
xd = zeros(S.n_end , ro_par.reps);
ee = zeros(S.n_end , ro_par.n_rfs*ro_par.reps);

for k=1:ro_par.reps
    
    yy(:,k) = S.rollouts(k).q(:,1);
    xd(:,k) = S.rollouts(k).dmp.xd(:,1);
    ee(:,(k-1)*ro_par.n_rfs+1:k*ro_par.n_rfs) = S.rollouts(k).dmp.eps;
    
end

figure(double(figID));
set(double(figID), 'units','normalized','outerposition',[0 0 1 1]);
clf;

% plot the noise-lesstrajectory
subplot(2,4,1);
hold on;
plot(t(1:S.n_end), xd);
plot(t(1:S.n_end), S.ref.r(1,:));
hold off;
xlabel('t');
ylabel('x');

% plot the noise-less end-effector trajectory
subplot(2,4,2);
hold on;
plot(t(1:S.n_end), yy);
plot(t(1:S.n_end), S.ref.r(1,:));
hold off;
xlabel('t');
ylabel('xd');

subplot(2,4,3);
plot(t(1:S.n_end),ee);
xlabel('time [s]');
ylabel('epsilon');

subplot(2,4,4);
plot(t(1:S.n_end),R(1:S.n_end));
xlabel('time [s]');
ylabel('Cost');

R_cum = rot90(rot90(cumsum(rot90(rot90(R)))));

subplot(2,4,5);
plot(t,R_cum);
ylabel(sprintf('R=sum(r)'));

% the eponentiated and rescaled cumulative reward (the same for all DMPs)
maxS = max(R_cum,[],2);
minS = min(R_cum,[],2);

h = 10;

expS = exp(-h*(R_cum - minS*ones(1,ro_par.reps))./((maxS-minS)*ones(1,ro_par.reps)));
subplot(2,4,6);
plot(t,expS);
ylabel(sprintf('scaled exp(R)'));

global dcps;

% the paramter vector
subplot(2,4,7);

bar(dcps(1).w);
ylabel('theta');
axis('tight');

subplot(2,4,8);
hold on;
plot(t(1:S.n_end), S_eval.rollouts(1).q(:,1));
plot(t(1:S.n_end), S_eval.rollouts(1).dmp.xd(:,1));
plot(t(1:S.n_end), S.ref.r(1,:));
hold off;
xlabel('t');
ylabel('xd');

drawnow;