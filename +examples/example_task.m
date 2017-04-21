clear; close all; clc;

figure
hold on;
scatter(0, 0.5, 40, 'Marker', 'x', 'LineWidth', 2);
scatter(3, 0.6, 40, 'Marker', 'x', 'LineWidth', 2);
scatter(8, 0.3, 40, 'Marker', 'x', 'LineWidth', 2);

xlim([-1, 9]);
ylim([0, 0.7]);

legend('start position', 'viapoint', 'goal position');

xlabel('time [s]');
ylabel('end effector x position');

t_plane = 6:0.1:8;
x_plane = 0.3*ones(1, length(t_plane));

figure
hold on;
scatter(0, 0.5, 40, 'Marker', 'x', 'LineWidth', 2);
scatter(3, 0.6, 40, 'Marker', 'x', 'LineWidth', 2);
plot(t_plane, x_plane);
scatter(8, 0.3, 40, 'Marker', 'x', 'LineWidth', 2);

xlim([-1, 9]);
ylim([0, 0.7]);

legend('start position', 'viapoint', 'viaplane', 'goal position');

xlabel('time [s]');
ylabel('end effector x position');