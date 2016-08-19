function print_progress(S, S_eval, forward_par_eval, figID)
% Plots the intermediate results of the running reward learning algorithm
% S: struct containing the roll-outs (noise included)
% S_eval: struct containing the noise-less roll-outs
% ro_par: struct containing the roll-out parameters
% figID: ID (number) used as figure ID

r = zeros(S.n_end, forward_par_eval.reps);

for k=1:forward_par_eval.reps
    r(:,k) = S.rollouts(k).r';
end            

for i=1:forward_par_eval.reps
    legendInfo{i} = sprintf('rep_%d',i);
end

t = S_eval.t;

yy = zeros(S.n_end , forward_par_eval.reps);
xd = zeros(S.n_end , forward_par_eval.reps);
ee = zeros(S.n_end , forward_par_eval.n_dmp_bf*forward_par_eval.reps);

for k=1:10
    
    yy(:,k) = S.rollouts(k).q(:,1);
    xd(:,k) = S.rollouts(k).dmp.xd(:,1);
    ee(:,(k-1)*forward_par_eval.n_dmp_bf+1:k*forward_par_eval.n_dmp_bf) = S.rollouts(k).dmp.eps;
    
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
hold on
plot(t(1:S.n_end),S_eval.rollouts(1).r(1:S.n_end));
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