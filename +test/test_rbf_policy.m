clear; close all; clc;

policy_par.duration = 10;
policy_par.Ts = 0.1;
policy_par.n_dmp_bf = 10;

p1 = dmp.RBF_policy(1, policy_par);

policy_par.goal = 1;
policy_par.t = p1.t;
policy_par.duration = 20;
r = refs.ref_trajectory(policy_par);
T = r.r(1:100)';

p1.batch_fit(T);

eps_std = 1;

[y, yd] = p1.run(zeros(policy_par.n_dmp_bf,1));

figure
hold on
plot(p1.t, y);
plot(p1.t, T);

figure
plot(p1.t, yd);