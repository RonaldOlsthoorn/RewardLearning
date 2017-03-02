function plot_overlay_viapoint
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

point = [0.3, 0.6];
point_t = 3;

figure(1)
subplot(1,3,1)
hold on;
scatter(point_t, point(1),...
    40, 'Marker', '+', 'LineWidth', 2, ...
    'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b');

subplot(1,3,2)
hold on;
scatter(point_t, point(2),...
    40, 'Marker', '+', 'LineWidth', 2, ...
    'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b');

subplot(1,3,3)
hold on;
scatter(point(1), point(2),...
    40, 'Marker', '+', 'LineWidth', 2, ...
    'MarkerEdgeColor', 'k', 'MarkerFaceColor', 'b');

end

