clear; close all; clc

%%
% set globals

posFig = [1 1 400 300];

% margins
marginX = 0.12;
marginY = 0.2;
widthX = (1-2.1*marginX)/2;
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
load('+output/computer/viapoint_advancedx_single_summary');
summary_struct_res_single = summary_struct;

load('+output/computer/viapoint_advancedx_multi_summary');
summary_struct_res_multi = summary_struct;

pos_single = zeros(2, length(summary_struct_res_single.batch_res(1).last_rollout.tool_positions(1,:)),...
    length(summary_struct_res_single.batch_res));

pos_multi = zeros(2, length(summary_struct_res_multi.batch_res(1).last_rollout.tool_positions(1,:)),...
    length(summary_struct_res_multi.batch_res));

t = summary_struct_res_single.batch_res(1).last_rollout.time;

t_plane = t(600:end);
plane = 0.5*ones(1, length(t_plane));

for i = 1:length(summary_struct_res_single.batch_res)
    
    pos_single(1,:,i) = summary_struct_res_single.batch_res(i).last_rollout.tool_positions(1,:);
    pos_single(2,:,i) = summary_struct_res_single.batch_res(i).last_rollout.tool_positions(2,:);
end

for i = 1:length(summary_struct_res_multi.batch_res)
    
    pos_multi(1,:,i) = summary_struct_res_multi.batch_res(i).last_rollout.tool_positions(1,:);
    pos_multi(2,:,i) = summary_struct_res_multi.batch_res(i).last_rollout.tool_positions(2,:);
end

mean_pos_single = mean(pos_single, 3);
var_pos_single = std(pos_single, 0, 3);

mean_pos_multi = mean(pos_multi, 3);
var_pos_multi = std(pos_multi, 0, 3);

figure;

% global
set(gcf,'WindowStyle','normal')
set(gcf, 'Position', posFig);
set(gcf, 'PaperPositionMode','auto');

xlabel('time [s]');
ylabel('x position end effector [m]');

hold on;

h2 = patch([t, fliplr(t)],[(mean_pos_single(1,:)+var_pos_single(1,:))'; flipud((mean_pos_single(1,:)-var_pos_single(1,:))')], 1, ...
     'FaceColor', [0.9,0.9,1], 'FaceAlpha', 0.5, 'EdgeColor', 'none'); 
 
h1 = plot(t, mean_pos_single(1,:), 'b');
h4 = plot(t_plane, plane, 'k');

h3 = scatter(3, 0.3, VPMarkerSize, 'Marker', VPMarkerType, ...
    'LineWidth', VPMarkerEdge, 'MarkerEdgeColor', VPMarkerEdgeColor, ...
    'MarkerFaceColor', VPMarkerFaceColor);

legend([h1, h2, h3, h4],'average SARL result', 'std SARL result',...
     'reference viapoint', 'reference viaplane', 'Location', 'southeast');
 
figure;

% global
set(gcf,'WindowStyle','normal')
set(gcf, 'Position', posFig);
set(gcf, 'PaperPositionMode','auto');

xlabel('time [s]');
ylabel('x position end effector [m]');

hold on;

h2 = patch([t, fliplr(t)],[(mean_pos_multi(1,:)+var_pos_multi(1,:))'; flipud((mean_pos_multi(1,:)-var_pos_multi(1,:))')], 1, ...
     'FaceColor', [0.9,0.9,1], 'FaceAlpha', 0.5, 'EdgeColor', 'none'); 
 
h1 = plot(t, mean_pos_multi(1,:), 'b');
h4 = plot(t_plane, plane, 'k');

h3 = scatter(3, 0.3, VPMarkerSize, 'Marker', VPMarkerType, ...
    'LineWidth', VPMarkerEdge, 'MarkerEdgeColor', VPMarkerEdgeColor, ...
    'MarkerFaceColor', VPMarkerFaceColor);

legend([h1, h2, h3, h4],'average SARL result', 'std SARL result',...
     'reference viapoint', 'reference viaplane', 'Location', 'southeast');
 
