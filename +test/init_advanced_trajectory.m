reference_par.trajectory = '2dof_advanced'; 
reference_par.start_tool = [0;0.5];
reference_par.goal_tool = [0.5;0.3];
reference_par.start_joint = [pi/6;(2*pi/3)];
reference_par.goal_joint = [0.2203;0.6767];
reference_par.duration = 8;
reference_par.Ts = .01;
reference_par.viapoint_t = 300;
reference_par.viapoint = [0.3; 0.6];
reference_par.viaplane_t = [601, 800];
reference_par.plane_dim = 'xy';
reference_par.plane_level = [0.5;0.3];

policy_par.type = 'dmp_ref_ik';
policy_par.dof = 2;
policy_par.n_rbfs = 20;
policy_par.duration = 8;
policy_par.Ts =  0.01;
policy_par.start = reference_par.start_tool;
policy_par.goal = reference_par.goal_tool;

[t, x_tool] = test.create_advanced_trajectory(reference_par);

figure
subplot(1,3,1)
hold on;
plot(t,x_tool(1,:));
scatter(reference_par.viapoint_t*reference_par.Ts, reference_par.viapoint(1));

subplot(1,3,2)
hold on;
plot(t,x_tool(2,:));
scatter(reference_par.viapoint_t*reference_par.Ts, reference_par.viapoint(2));

subplot(1,3,3)
hold on;
plot(x_tool(1,:), x_tool(2,:));
scatter( reference_par.viapoint(1), reference_par.viapoint(2));

reference = init.init_reference(reference_par);
policy = init.init_policy(policy_par, reference);

policy.DoFs(1).batch_fit(x_tool(1,:)');
policy.DoFs(2).batch_fit(x_tool(2,:)');

trajectory = policy.create_noiseless_trajectory();

figure

subplot(1,5,1);
hold on;
plot(t,x_tool(1,:));
plot(t, trajectory.policy.dof(1).xd(1,:));
scatter(reference_par.viapoint_t*reference_par.Ts, reference_par.viapoint(1));

subplot(1,5,2);
hold on;
plot(t,x_tool(2,:));
plot(t, trajectory.policy.dof(2).xd(1,:));
scatter(reference_par.viapoint_t*reference_par.Ts, reference_par.viapoint(2));

subplot(1,5,3);
hold on;
plot(x_tool(1,:), x_tool(2,:));
plot(trajectory.policy.dof(1).xd(1,:), trajectory.policy.dof(2).xd(1,:));
scatter(reference_par.viapoint(1), reference_par.viapoint(2));

subplot(1,5,4);
bar(policy.DoFs(1).w);    

subplot(1,5,5);
bar(policy.DoFs(2).w); 