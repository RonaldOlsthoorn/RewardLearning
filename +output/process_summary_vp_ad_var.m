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

posFig = [1 1 1350 550];

%yLimTrajX;
%yLimTrajY;
yLimTrajXY = [0.25 0.75];

yLimCon = [-0.08 0.03];

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
PPMarkerEdgeColor = 'b';
PPMarkerFaceColor = 'w';

%%
load('+output/viapoint_advancedx_var_single_summary');
load('+output/viapoint_advancedx_static');

pos = zeros(2, length(summary_struct.batch_res(1).last_rollout.tool_positions(1,:)),...
    length(summary_struct.batch_res));

opt_pos = to_save.Reward_trace(end).tool_positions;

t = summary_struct.batch_res(1).last_rollout.time;

t_plane = t(600:end);
plane = 0.5*ones(1, length(t_plane));

pos_init = summary_struct.batch_res(1).first_rollout.tool_positions;

for i = 1:length(summary_struct.batch_res)
    
    pos(1,:,i) = summary_struct.batch_res(i).last_rollout.tool_positions(1,:);
    pos(2,:,i) = summary_struct.batch_res(i).last_rollout.tool_positions(2,:);
end

mean_pos = mean(pos, 3);
var_pos = std(pos, 0, 3);

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

patch([t, fliplr(t)],[(mean_pos(1,:)+var_pos(1,:))'; flipud((mean_pos(1,:)-var_pos(1,:))')], 1, ...
     'FaceColor', [0.9,0.9,1], 'EdgeColor', 'none'); % This is the grey area in the plot.
 
plot(t, mean_pos(1,:), 'b');
plot(t, opt_pos(1,:), 'r');
h4 = plot(t_plane, plane, 'k');

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
ylim(yLimTrajXY);
set(gca, 'Position', pos);
xlabel('time [s]');
ylabel('y position end effector [m]');

hold on;
patch([t, fliplr(t)],[(mean_pos(2,:)+var_pos(2,:))'; flipud((mean_pos(2,:)-var_pos(2,:))')], 1, ...
     'FaceColor', [0.9,0.9,1], 'EdgeColor', 'none'); % This is the grey area in the plot.
 
plot(t, mean_pos(2,:), 'b');
plot(t, opt_pos(2,:), 'r');

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
ylim(yLimTrajXY);
set(gca, 'Position', pos);
xlabel('x position end effector [m]');
ylabel('y position end effector [m]');

hold on;
h1 = patch([(mean_pos(1,:))'; flipud((mean_pos(1,:))')], ...
    [(mean_pos(2,:)+var_pos(2,:))'; flipud((mean_pos(2,:)-var_pos(2,:))')], 1, ...
     'FaceColor', [0.9,0.9,1], 'EdgeColor', 'none'); % This is the grey area in the plot.
 
h2 = plot(mean_pos(1,:), mean_pos(2,:), 'b');
h3 = plot(opt_pos(1,:), opt_pos(2,:), 'r');

% h4 = scatter(mean_pos(1,300), mean_pos(2,300), PPMarkerSize, 'Marker', PPMarkerType, ...
%     'LineWidth', PPMarkerEdge, 'MarkerEdgeColor', PPMarkerEdgeColor, ...
%     'MarkerFaceColor', PPMarkerFaceColor);
% 
% h5 = scatter(opt_pos(1,300), opt_pos(2,300), PPMarkerSize, 'Marker', PPMarkerType, ...
%     'LineWidth', PPMarkerEdge, 'MarkerEdgeColor', 'r', ...
%     'MarkerFaceColor', PPMarkerFaceColor);

h6 = scatter(0.3, 0.6, VPMarkerSize, 'Marker', VPMarkerType, ...
    'LineWidth', VPMarkerEdge, 'MarkerEdgeColor', VPMarkerEdgeColor, ...
    'MarkerFaceColor', VPMarkerFaceColor);

legend([h2, h1, h3, h4, h6],'average SARL result', 'std SARL result', 'RL result', ...
    'reference viapoint', 'reference viaplane', 'Location', 'southwest');

suptitle('resulting trajectory');

savefig('+output/advancedx-var/trajectory_single_noise_sum');
print('+output/advancedx-var/trajectory_single_noise_sum', '-depsc');

close all;

%%

figure;

xlabel('iteration');
ylabel('return');
title('Convergence');

R = zeros(49,...
    length(summary_struct.batch_res));

R_var = zeros(49,...
    length(summary_struct.batch_res));

R_true = zeros(49,...
    length(summary_struct.batch_res));

for i = 1:length(summary_struct.batch_res)
    
    R(1:49,i) = summary_struct.batch_res(i).R(1:49)';
    R_var(1:49,i) = summary_struct.batch_res(i).R_var(1:49)';
    R_true(1:49,i) = summary_struct.batch_res(i).R_true(1:49)';   
end

mean_r = mean(R,2);
var_r = mean(R_var, 2);

mean_r_true = mean(R_true,2);
var_r_true = var(R_true,0,2);

it = 1:length(mean_r);

hold on;
h1 = patch([it, fliplr(it)],[(mean_r+var_r); flipud((mean_r-var_r))], 1, ...
     'FaceColor', [0.9,0.9,1], 'EdgeColor', 'none'); 

h2 = plot(mean_r, 'b');

h3 = plot(mean_r_true, 'r');

ylim(yLimCon);

legend([h2 h1 h3], ...
    'average reward model return', 'std reward model return', 'true return',...
        'location', 'southeast');
    
savefig('+output/advancedx-var/convergence_single_noise_sum');
print('+output/advancedx-var/convergence_single_noise_sum', '-depsc');

close all;

%%
load('+output/viapoint_advancedx_var_multi_summary');

pos = zeros(2, length(summary_struct.batch_res(1).last_rollout.tool_positions(1,:)),...
    length(summary_struct.batch_res));

opt_pos = to_save.Reward_trace(end).tool_positions;

t = summary_struct.batch_res(1).last_rollout.time;

pos_init = summary_struct.batch_res(1).first_rollout.tool_positions;

for i = 1:length(summary_struct.batch_res)
    
    pos(1,:,i) = summary_struct.batch_res(i).last_rollout.tool_positions(1,:);
    pos(2,:,i) = summary_struct.batch_res(i).last_rollout.tool_positions(2,:);
end

mean_pos = mean(pos, 3);
var_pos = std(pos, 0, 3);

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

patch([t, fliplr(t)],[(mean_pos(1,:)+var_pos(1,:))'; flipud((mean_pos(1,:)-var_pos(1,:))')], 1, ...
     'FaceColor', [0.9,0.9,1], 'EdgeColor', 'none'); % This is the grey area in the plot.
 
plot(t, mean_pos(1,:), 'b');
plot(t, opt_pos(1,:), 'r');
h4 = plot(t_plane, plane, 'k');

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
ylim(yLimTrajXY);
set(gca, 'Position', pos);
xlabel('time [s]');
ylabel('y position end effector [m]');

hold on;
patch([t, fliplr(t)],[(mean_pos(2,:)+var_pos(2,:))'; flipud((mean_pos(2,:)-var_pos(2,:))')], 1, ...
     'FaceColor', [0.9,0.9,1], 'EdgeColor', 'none'); % This is the grey area in the plot.
 
plot(t, mean_pos(2,:), 'b');
plot(t, opt_pos(2,:), 'r');

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
ylim(yLimTrajXY);
set(gca, 'Position', pos);
xlabel('x position end effector [m]');
ylabel('y position end effector [m]');

hold on;
h1 = patch([(mean_pos(1,:))'; flipud((mean_pos(1,:))')], ...
    [(mean_pos(2,:)+var_pos(2,:))'; flipud((mean_pos(2,:)-var_pos(2,:))')], 1, ...
     'FaceColor', [0.9,0.9,1], 'EdgeColor', 'none'); % This is the grey area in the plot.
 
h2 = plot(mean_pos(1,:), mean_pos(2,:), 'b');
h3 = plot(opt_pos(1,:), opt_pos(2,:), 'r');

% h4 = scatter(mean_pos(1,300), mean_pos(2,300), PPMarkerSize, 'Marker', PPMarkerType, ...
%     'LineWidth', PPMarkerEdge, 'MarkerEdgeColor', PPMarkerEdgeColor, ...
%     'MarkerFaceColor', PPMarkerFaceColor);
% 
% h5 = scatter(opt_pos(1,300), opt_pos(2,300), PPMarkerSize, 'Marker', PPMarkerType, ...
%     'LineWidth', PPMarkerEdge, 'MarkerEdgeColor', 'r', ...
%     'MarkerFaceColor', PPMarkerFaceColor);

h6 = scatter(0.3, 0.6, VPMarkerSize, 'Marker', VPMarkerType, ...
    'LineWidth', VPMarkerEdge, 'MarkerEdgeColor', VPMarkerEdgeColor, ...
    'MarkerFaceColor', VPMarkerFaceColor);

legend([h2, h1, h3, h4, h6],'average SARL result', 'std SARL result', 'RL result', ...
    'reference viapoint', 'reference viaplane', 'Location', 'southwest');

suptitle('resulting trajectory');


savefig('+output/advancedx-var/trajectory_multi_noise_sum');
print('+output/advancedx-var/trajectory_multi_noise_sum', '-depsc');

close all;

%%

R = zeros(length(summary_struct.batch_res), 49, 4);

R_var = zeros(length(summary_struct.batch_res), 49, 4);

R_true = zeros(length(summary_struct.batch_res), 49, 4);

for i = 1:length(summary_struct.batch_res)
    
    R(i,:,:) = summary_struct.batch_res(i).R(1:49,:);
    R_var(i,:,:) = summary_struct.batch_res(i).R_var(1:49,:);
    R_true(i,:,:) = summary_struct.batch_res(i).R_true(1:49,:);   
end

mean_r = squeeze(mean(R,1));
var_r = squeeze(mean(R_var, 1));

mean_r_true = squeeze(mean(R_true,1));
var_r_true = squeeze(var(R_true,0,1));

it = 1:length(mean_r);

figure;
set(gcf,'WindowStyle','normal')
set(gcf, 'Position', posFigReward);
set(gcf, 'PaperPositionMode','auto');

%suptitle('Return convergence');
    
x = marginXReward;
y = 2*marginYReward+heightYReward;

for i = 1:4
    
    subplot(2,2,i);
    hold on;
    patch([it, fliplr(it)],[(mean_r(:,i)+var_r(:,i)); flipud((mean_r(:,i)-var_r(:,i)))], 1, ...
     'FaceColor', [0.9,0.9,1], 'EdgeColor', 'none'); 
    h1 = plot(mean_r(:,i), 'b');
    h2 = plot(mean_r_true(:,i), 'r');
        
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
        
    xlabel('iteration');
    ylabel('return noiseless rollout');
end    


legend([h1 h2], ...
    'reward model return', 'true return',...
        'location', 'southeast');
    
savefig('+output/advancedx-var/return_flat_multi_noise_sum');
print('+output/advancedx-var/return_flat_multi_noise_sum', '-depsc');

close all;
