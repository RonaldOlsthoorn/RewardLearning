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

xx = zeros(S.n_end , forward_par_eval.reps);
yy = zeros(S.n_end , forward_par_eval.reps);
zz = zeros(S.n_end , forward_par_eval.reps);

ee = zeros(S.n_end , forward_par_eval.n_dmp_bf*forward_par_eval.reps);

for k=1:10
    
    xx(:,k) = S.rollouts(k).ef_positions(1,:);
    yy(:,k) = S.rollouts(k).ef_positions(2,:);
    zz(:,k) = S.rollouts(k).ef_positions(3,:);
     
    ee(:,(k-1)*forward_par_eval.n_dmp_bf+1:k*forward_par_eval.n_dmp_bf) = S.rollouts(k).dmp.eps; 
end

figure(double(figID));
set(double(figID), 'units','normalized','outerposition',[0 0 1 1]);
clf;

% plot the samples
subplot(2,3,1);
hold on;
plot(t(1:S.n_end), xx);
hold off;
xlabel('t');
ylabel('x');
legend(legendInfo);

% plot the samples
subplot(2,3,2);
hold on;
plot(t(1:S.n_end), yy);
hold off;
xlabel('t');
ylabel('y');
legend(legendInfo);

% plot the samples
subplot(2,3,3);
hold on;
plot(t(1:S.n_end), zz);
hold off;
xlabel('t');
ylabel('z');
legend(legendInfo);

subplot(2,3,4);
hold on;
plot(t(1:S.n_end), S_eval.rollouts(1).ef_positions(1,:));
plot(t(1:S.n_end), S.ref.r_tool(1,:));
hold off;
xlabel('t');
ylabel('x');

subplot(2,3,5);
hold on;
plot(t(1:S.n_end), S_eval.rollouts(1).ef_positions(2,:));
plot(t(1:S.n_end), S.ref.r_tool(2,:));
hold off;
xlabel('t');
ylabel('y');

subplot(2,3,6);
hold on;
plot(t(1:S.n_end), S_eval.rollouts(1).ef_positions(3,:));
plot(t(1:S.n_end), S.ref.r_tool(3,:));
hold off;
xlabel('t');
ylabel('z');

figure;
% the paramter vector
bar(S.dmps(1).w);
ylabel('theta');
axis('tight');

drawnow;