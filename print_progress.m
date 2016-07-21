function print_progress(S, S_eval, ro_par, figID)
% Plots the intermediate results of the running PI2 algorithm
% D: struct containing the roll-outs (noise included)
% D_eval: struct containing the noise-less roll-outs
% figID: ID (number) used as figure ID

r = zeros(S.n_end, ro_par.reps);

for k=1:ro_par.reps
    r(:,k) = S.rollouts(k).r';
end            

for i=1:ro_par.reps
    legendInfo{i} = sprintf('rep_%d',i);
end

t = S_eval.t;

yy = zeros(S.n_end , ro_par.reps);
xd = zeros(S.n_end , ro_par.reps);
ee = zeros(S.n_end , ro_par.n_dmp_bf*ro_par.reps);

for k=1:ro_par.reps
    
    yy(:,k) = S.rollouts(k).q(:,1);
    xd(:,k) = S.rollouts(k).dmp.xd(:,1);
    ee(:,(k-1)*ro_par.n_dmp_bf+1:k*ro_par.n_dmp_bf) = S.rollouts(k).dmp.eps;
    
end

global dcps;

figure(double(figID));
set(double(figID), 'units','normalized','outerposition',[0 0 1 1]);
clf;

% plot the samples
subplot(2,3,1);
hold on;
plot(t(1:S.n_end), yy);
plot(t(1:S.n_end), S.ref.r(1,:));
hold off;
xlabel('t');
ylabel('x');
legend(legendInfo);

subplot(2,3,2);
hold on;
plot(t(1:S.n_end), S_eval.rollouts(1).q(:,1));
plot(t(1:S.n_end), S_eval.rollouts(1).dmp.xd(:,1));
plot(t(1:S.n_end), S.ref.r(1,:));
hold off;
xlabel('t');
ylabel('xd');

subplot(2,3,3);
plot(t(1:S.n_end),S_eval.rollouts(1).r(1:S.n_end));
plot(t(1:S.n_end),query_expert(S_eval.rollouts(1).sum_out), 0);
xlabel('time [s]');
ylabel('Cost');

subplot(2,3,4);
hold on;
plot(t(1:S.n_end), S_eval.rollouts(1).sum_out(:,1));
hold off;
xlabel('t');
ylabel('sum outcomes');

% the paramter vector
subplot(2,3,6);
bar(dcps(1).w);
ylabel('theta');
axis('tight');

drawnow;