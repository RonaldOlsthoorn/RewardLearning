clear; close all; clc

%%
% set globals
posFigCon = [1 1 800 500];
posFigReward = [1 1 1000 700];

% margins
marginXReward = 0.12;
marginYReward = 0.1;
widthXReward = (1-3*marginXReward)/2;
heightYReward = (1-3*marginYReward)/2;

posFig = [1 1 1000 500];

% margins
marginX = 0.07;
marginY = 0.1;
widthX = (1-4*marginX)/3;
heightY = (1-2*marginY);

% set appearance of viapoint
VPMarkerSize = 60;
VPMarkerType = '+';
VPMarkerEdge = 2;
VPMarkerEdgeColor = 'k';
VPMarkerFaceColor = 'w';

% set appearance of cross point
PPMarkerSize = 60;
PPMarkerType = '+';
PPMarkerEdge = 2;
PPMarkerEdgeColor = 'r';
PPMarkerFaceColor = 'w';

%%
load('+output/viapoint_single_summary');

pos = zeros(2, length(summary_struct.batch_res(1).last_rollout.tool_positions(1,:)),...
    length(summary_struct.batch_res));

t = summary_struct.batch_res(1).last_rollout.time;

pos_init = summary_struct.batch_res(1).first_rollout.tool_positions;

for i = 1:length(summary_struct.batch_res)
    
    pos(1,:,i) = summary_struct.batch_res(i).last_rollout.tool_positions(1,:);
    pos(2,:,i) = summary_struct.batch_res(i).last_rollout.tool_positions(2,:);
end

mean_pos = mean(pos, 3);

figure;

% global
set(gcf,'WindowStyle','normal')
set(gcf, 'Position', posFig);
set(gcf, 'PaperPositionMode','auto');

% set margins figures
subplot(1,3,1);
x = marginX;
pos = get(gca, 'Position');
pos(1) = x;
pos(2) = marginY;
pos(3) = widthX;
pos(4) = heightY;
set(gca, 'Position', pos);
xlabel('time [s]');
ylabel('x position end effector [m]');

hold on;
plot(t, mean_pos(1,:), 'b');
scatter(3, 0.3, VPMarkerSize, 'Marker', VPMarkerType, ...
    'LineWidth', VPMarkerEdge, 'MarkerEdgeColor', VPMarkerEdgeColor, ...
    'MarkerFaceColor', VPMarkerFaceColor);

subplot(1,3,2);
x = x+widthX+marginX;
pos = get(gca, 'Position');
pos(1) = x;
pos(2) = marginY;
pos(3) = widthX;
pos(4) = heightY;
set(gca, 'Position', pos);
xlabel('time [s]');
ylabel('y position end effector [m]');

hold on;
plot(t, mean_pos(2,:), 'b');
scatter(3, 0.6, VPMarkerSize, 'Marker', VPMarkerType, ...
    'LineWidth', VPMarkerEdge, 'MarkerEdgeColor', VPMarkerEdgeColor, ...
    'MarkerFaceColor', VPMarkerFaceColor);


subplot(1,3,3);
x = x+widthX+marginX;
pos = get(gca, 'Position');
pos(1) = x;
pos(2) = marginY;
pos(3) = widthX;
pos(4) = heightY;
set(gca, 'Position', pos);
xlabel('x position end effector [m]');
ylabel('y position end effector [m]');

hold on;
plot(mean_pos(1,:), mean_pos(2,:), 'b');
scatter(0.3, 0.6, VPMarkerSize, 'Marker', VPMarkerType, ...
    'LineWidth', VPMarkerEdge, 'MarkerEdgeColor', VPMarkerEdgeColor, ...
    'MarkerFaceColor', VPMarkerFaceColor);
scatter(mean_pos(1,300), mean_pos(2,300), PPMarkerSize, 'Marker', PPMarkerType, ...
    'LineWidth', PPMarkerEdge, 'MarkerEdgeColor', PPMarkerEdgeColor, ...
    'MarkerFaceColor', PPMarkerFaceColor);

suptitle('Average resulting trajectory');

savefig('+output/viapoint/trajectory_single_noise_sum');
print('+output/viapoint/trajectory_single_noise_sum', '-depsc');

figure(3);

xlabel('iteration');
ylabel('return noiseless rollout');

children = get(gca, 'Children');

title('Return convergence');

legend([children(1) children(2)], ...
    'reward model return', 'true return',...
        'location', 'southeast');
    
savefig('+output/viapoint/convergence_single_noise');
print('+output/viapoint/convergence_single_noise', '-depsc');

close all;

%%
load('+output/viapoint_multi');


figure;

set(gcf,'WindowStyle','normal')
set(gcf, 'Position', posFig);
set(gcf, 'PaperPositionMode','auto');

% set margins figures
x = marginX;
subplot(1,3,1);
pos = get(gca, 'Position');
pos(1) = x;
pos(2) = marginY;
pos(3) = widthX;
pos(4) = heightY;
set(gca, 'Position', pos);

x = x+widthX+marginX;

subplot(1,3,2);
pos = get(gca, 'Position');
pos(1) = x;
pos(2) = marginY;
pos(3) = widthX;
pos(4) = heightY;
set(gca, 'Position', pos);

x = x+widthX+marginX;

subplot(1,3,3);
pos = get(gca, 'Position');
pos(1) = x;
pos(2) = marginY;
pos(3) = widthX;
pos(4) = heightY;
set(gca, 'Position', pos);

children = get(gca, 'Children');

suptitle('Resulting trajectory')

legend([children(4) children(3) children(1) children(2)], ...
    'First rollout','Final rollout', 'Reference via point', 'Final rollout viapoint', ...
        'location', 'southwest');

savefig('+output/viapoint/trajectory_multi_noise');
print('+output/viapoint/trajectory_multi_noise', '-depsc');

figure(3);

xlabel('iteration');
ylabel('return noiseless rollout');

children = get(gca, 'Children');

title('Return convergence');

legend([children(1) children(2)], ...
    'reward model return', 'true return',...
        'location', 'southeast');
    
savefig('+output/viapoint/convergence_multi_noise');
print('+output/viapoint/convergence_multi_noise', '-depsc');

figure(6);

set(gcf,'WindowStyle','normal')
set(gcf, 'Position', posFigReward);
set(gcf, 'PaperPositionMode','auto');

x = marginXReward;
y = 2*marginYReward+heightYReward;

for i = 1:4
    
    subplot(2,2,i);
    
    children = get(gca, 'Children');
    delete(children(2));
    delete(children(3));
    
    pos = get(gca, 'Position');
    pos(1) = x;
    pos(2) = y;
    pos(3) = widthXReward;
    pos(4) = heightYReward;
    set(gca, 'Position', pos);
    
    x = x + ((-1)^(i-1))*(widthXReward+marginXReward);
    
    if i==2
        y = y - heightYReward - marginYReward;
    end
    
    title(strcat('segment ', {' '}, num2str(i)));
    colorbar();
end

suptitle('Multi segment return function');
    
savefig('+output/viapoint/return_flat_multi_noise');
print('+output/viapoint/return_flat_multi_noise', '-depsc');

close all;

%%
load('+output/viapoint_single');
to_save_single = to_save;

load('+output/viapoint_multi');
to_save_multi = to_save;

% Load saved figures
c=hgload('+output/viapoint/convergence_single_noise.fig');
k=hgload('+output/viapoint/convergence_multi_noise.fig');
% Prepare subplots

figure
set(gcf,'WindowStyle','normal')
set(gcf, 'Position', posFigCon);
set(gcf, 'PaperPositionMode','auto');

h(1)=subplot(1,2,1);
h(2)=subplot(1,2,2);
% Paste figures on the subplots
copyobj(allchild(get(c,'CurrentAxes')),h(1));
copyobj(allchild(get(k,'CurrentAxes')),h(2));
% Add legends

subplot(1,2,1)
l(1) = legend(h(1), 'reward model return', 'true return',...
        'location', 'southeast');
xlabel('iteration');
ylabel('return noiseless rollout');
title('single GP return convergence');


subplot(1,2,2)
l(2) = legend(h(2), 'reward model return', 'true return',...
        'location', 'southeast');
xlabel('iteration');
ylabel('return noiseless rollout');
title('multi GP return convergence');

suptitle('Return convergence')

savefig('+output/viapoint/convergence_combi_noise');
print('+output/viapoint/convergence_combi_noise', '-depsc');


close all; clear; clc;