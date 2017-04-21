clear; close all; clc;

protocol_s = 'viapoint_static';

protocol_handle = str2func(strcat('protocols.', protocol_s));
protocol = protocol_handle();

import plant.Plant;
import environment.Environment;

reference = init.init_reference(protocol.reference_par);
plant = init.init_plant(protocol.plant_par, protocol.controller_par);
plant.set_init_state(reference.init_state);

policy = init.init_policy(protocol.policy_par, reference);
agent = init.init_agent(protocol.agent_par, policy);

reward_model = init.init_reward_model(protocol.reward_model_par,...
    reference);

environment = init.init_environment(protocol.env_par, ...
    plant, reward_model, agent, reference);

batch_trajectory = agent.get_batch_trajectories();

batch_rollouts = environment.batch_run(batch_trajectory);

rollout = batch_rollouts.get_rollout(1);

figure(plant.handle_batch_figure);

subplot(1,2,1)
hold on
plot(rollout.time, rollout.tool_positions(1,:));
scatter(1, mean(rollout.tool_positions(1,1:200)), ...
    40, 'Marker', '+', 'LineWidth', 2, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b');
scatter(3, mean(rollout.tool_positions(1,201:400)), ...
    40, 'Marker', '+', 'LineWidth', 2, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b');
scatter(5, mean(rollout.tool_positions(1,401:600)), ...
    40, 'Marker', '+', 'LineWidth', 2, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b');
scatter(7, mean(rollout.tool_positions(1,601:800)), ...
    40, 'Marker', '+', 'LineWidth', 2, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b');
xlabel('t [s]');
ylabel('x_{ef} [m]');

YLim = get(gca, 'YLim');

x = [2 2];
y = [YLim(1) YLim(2)];
line(x,y,'Color','red','LineStyle','--');

x = [4 4];
line(x,y,'Color','red','LineStyle','--');

x = [6 6];
line(x,y,'Color','red','LineStyle','--');

set(gca, 'YLim', YLim);

subplot(1,2,2)
hold on
plot(rollout.time, rollout.tool_positions(2,:));
scatter(1, mean(rollout.tool_positions(2,1:200)), ...
    40, 'Marker', '+', 'LineWidth', 2, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b');
scatter(3, mean(rollout.tool_positions(2,201:400)), ...
    40, 'Marker', '+', 'LineWidth', 2, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b');
scatter(5, mean(rollout.tool_positions(2,401:600)), ...
    40, 'Marker', '+', 'LineWidth', 2, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b');
scatter(7, mean(rollout.tool_positions(2,601:800)), ...
    40, 'Marker', '+', 'LineWidth', 2, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b');
xlabel('t [s]');
ylabel('y_{ef} [m]');

YLim = get(gca, 'YLim');

x = [2 2];
y = [YLim(1) YLim(2)];
line(x,y,'Color','red','LineStyle','--');

x = [4 4];
line(x,y,'Color','red','LineStyle','--');

x = [6 6];
line(x,y,'Color','red','LineStyle','--');

set(gca, 'YLim', YLim);