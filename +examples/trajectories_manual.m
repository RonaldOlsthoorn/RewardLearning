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
load('+output/manual/viapoint_advancedx_single_manual');
struct_res_single = res_struct;

load('+output/manual/viapoint_advancedx_multi_manual');
struct_res_multi = res_struct;

pos_single = struct_res_single.Reward_trace(end).tool_positions;

pos_multi = struct_res_multi.Reward_trace(end).tool_positions;

t = struct_res_single.Reward_trace(end).time;

t_plane = t(600:end);
plane = 0.5*ones(1, length(t_plane));

figure;

% global
set(gcf,'WindowStyle','normal')
set(gcf, 'Position', posFig);
set(gcf, 'PaperPositionMode','auto');

xlabel('time [s]');
ylabel('x position end effector [m]');

hold on;

h1 = plot(t, pos_single(1,:), 'b');
h3 = plot(t_plane, plane, 'k');

h2 = scatter(3, 0.3, VPMarkerSize, 'Marker', VPMarkerType, ...
    'LineWidth', VPMarkerEdge, 'MarkerEdgeColor', VPMarkerEdgeColor, ...
    'MarkerFaceColor', VPMarkerFaceColor);

legend([h1, h2, h3],'SARL result', ...
     'reference viapoint', 'reference viaplane', 'Location', 'southeast');
 
figure;

% global
set(gcf,'WindowStyle','normal')
set(gcf, 'Position', posFig);
set(gcf, 'PaperPositionMode','auto');

xlabel('time [s]');
ylabel('x position end effector [m]');

hold on;
 
h1 = plot(t, pos_multi(1,:), 'b');
h3 = plot(t_plane, plane, 'k');

h2 = scatter(3, 0.3, VPMarkerSize, 'Marker', VPMarkerType, ...
    'LineWidth', VPMarkerEdge, 'MarkerEdgeColor', VPMarkerEdgeColor, ...
    'MarkerFaceColor', VPMarkerFaceColor);

legend([h1, h2, h3],'average SARL result', ...
     'reference viapoint', 'reference viaplane', 'Location', 'southeast');
 
