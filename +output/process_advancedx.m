clear; close all; clc

% Create plots of the results of the following protocols
% viapoint_advancedx_single viapoint_advancedx_multi
%
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

%yLimTrajX;
%yLimTrajY;
yLimTrajXY = [0.25 0.75];

yLimCon = [-0.2 0.12];

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
load('+output/computer/viapoint_advancedx_single');
op = output.Output.from_struct(res_struct);
% op.print();

trajectory = op.Reward_trace(end).tool_positions;
time = op.Reward_trace(end).time;

figure;

% global
set(gcf,'WindowStyle','normal')
set(gcf, 'Position', posFig);
set(gcf, 'PaperPositionMode','auto');

% set margins figures
x = marginX;
subplot(1,3,1);
hold on;
plot(time, trajectory(1,:), 'b');
scatter(3, 0.3, VPMarkerSize, 'Marker', VPMarkerType, ...
    'LineWidth', VPMarkerEdge, 'MarkerEdgeColor', VPMarkerEdgeColor, ...
    'MarkerFaceColor', VPMarkerFaceColor);

pos = get(gca, 'Position');
pos(1) = x;
pos(2) = marginY;
pos(3) = widthX;
pos(4) = heightY;
set(gca, 'Position', pos);

x = x+widthX+marginX;

subplot(1,3,2);
hold on;
plot(time, trajectory(2,:), 'b');
scatter(3, 0.6, VPMarkerSize, 'Marker', VPMarkerType, ...
    'LineWidth', VPMarkerEdge, 'MarkerEdgeColor', VPMarkerEdgeColor, ...
    'MarkerFaceColor', VPMarkerFaceColor);
pos = get(gca, 'Position');
pos(1) = x;
pos(2) = marginY;
pos(3) = widthX;
pos(4) = heightY;
set(gca, 'Position', pos);

x = x+widthX+marginX;

subplot(1,3,3);
hold on;
plot(trajectory(1,:), trajectory(2,:), 'b');
scatter(0.3, 0.6, VPMarkerSize, 'Marker', VPMarkerType, ...
    'LineWidth', VPMarkerEdge, 'MarkerEdgeColor', VPMarkerEdgeColor, ...
    'MarkerFaceColor', VPMarkerFaceColor);
pos = get(gca, 'Position');
pos(1) = x;
pos(2) = marginY;
pos(3) = widthX;
pos(4) = heightY;
set(gca, 'Position', pos);

children = get(gca, 'Children');

suptitle('Resulting trajectory')

% legend([children(4) children(3) children(1) children(2)], ...
%     'First rollout','Final rollout', 'Reference via point', 'Final rollout viapoint', ...
%         'location', 'southwest');
    
% savefig('+output/advancedx/trajectory_single_noise');
% print('+output/advancedx/trajectory_single_noise', '-depsc');

close all;

%%

R = zeros(length(op.Reward_trace),1);
R_var = zeros(length(op.Reward_trace),1);
R_true = zeros(length(op.Reward_trace),1);

for i = 1:length(R)
    
    R(i) = op.Reward_trace(i).R;
    R_var(i) = op.Reward_trace(i).R_var;
    R_true(i) = op.Reward_trace(i).R_true;   
end

it = 1:length(R);

figure;
hold on;
h2 = patch([it, fliplr(it)],[(R+R_var); flipud((R-R_var))], 1, ...
     'FaceColor', [0.9,0.9,1], 'EdgeColor', 'none'); 
h1 = plot(R, 'b');
h3 = plot(R_true, 'r');

xlabel('iteration');
ylabel('return');

title('Convergence');

ylim(yLimCon);

legend([h1 h2 h3], ...
     'reward model return', 'std reward model return', 'true return',...
         'location', 'southeast');
    
savefig('+output/advancedx/convergence_single_noise');
print('+output/advancedx/convergence_single_noise', '-depsc');

close all;

%%
load('+output/computer/viapoint_advancedx_multi');
op = output.Output.from_struct(res_struct);

trajectory = op.Reward_trace(end).tool_positions;
time = op.Reward_trace(end).time;

figure;

set(gcf,'WindowStyle','normal')
set(gcf, 'Position', posFig);
set(gcf, 'PaperPositionMode','auto');

% set margins figures
x = marginX;
subplot(1,3,1);
hold on;
plot(time, trajectory(1,:), 'b');
scatter(3, 0.3, VPMarkerSize, 'Marker', VPMarkerType, ...
    'LineWidth', VPMarkerEdge, 'MarkerEdgeColor', VPMarkerEdgeColor, ...
    'MarkerFaceColor', VPMarkerFaceColor);
pos = get(gca, 'Position');
pos(1) = x;
pos(2) = marginY;
pos(3) = widthX;
pos(4) = heightY;
set(gca, 'Position', pos);

x = x+widthX+marginX;

subplot(1,3,2);
hold on;
plot(time, trajectory(2,:), 'b');
scatter(3, 0.6, VPMarkerSize, 'Marker', VPMarkerType, ...
    'LineWidth', VPMarkerEdge, 'MarkerEdgeColor', VPMarkerEdgeColor, ...
    'MarkerFaceColor', VPMarkerFaceColor);
pos = get(gca, 'Position');
pos(1) = x;
pos(2) = marginY;
pos(3) = widthX;
pos(4) = heightY;
set(gca, 'Position', pos);

x = x+widthX+marginX;

subplot(1,3,3);
hold on;
plot(trajectory(1,:), trajectory(2,:), 'b');
scatter(0.3, 0.6, VPMarkerSize, 'Marker', VPMarkerType, ...
    'LineWidth', VPMarkerEdge, 'MarkerEdgeColor', VPMarkerEdgeColor, ...
    'MarkerFaceColor', VPMarkerFaceColor);
pos = get(gca, 'Position');
pos(1) = x;
pos(2) = marginY;
pos(3) = widthX;
pos(4) = heightY;
set(gca, 'Position', pos);

children = get(gca, 'Children');

suptitle('Resulting trajectory')

% legend([children(4) children(3) children(1) children(2)], ...
%     'First rollout','Final rollout', 'Reference via point', 'Final rollout viapoint', ...
%         'location', 'southwest');

% savefig('+output/advancedx/trajectory_multi_noise');
% print('+output/advancedx/trajectory_multi_noise', '-depsc');

close all;

%%

R = zeros(length(op.Reward_trace),4);
R_var = zeros(length(op.Reward_trace),4);
R_true = zeros(length(op.Reward_trace),4);

for i = 1:length(op.Reward_trace)
    
    R(i,:) = op.Reward_trace(i).R_segments';
    R_var(i,:) = op.Reward_trace(i).R_var';
    R_true(i,:) = op.Reward_trace(i).R_true';   
end

it = 1:length(R);

figure;
set(gcf,'WindowStyle','normal')
set(gcf, 'Position', posFigReward);
set(gcf, 'PaperPositionMode','auto');

suptitle('Convergence');
    
x = marginXReward;
y = 2*marginYReward+heightYReward;

for i = 1:4
    
    subplot(2,2,i);
    hold on;
    h2 = patch([it, fliplr(it)],[(R(:,i)+R_var(:,i)); flipud((R(:,i)-R_var(:,i)))], 1, ...
     'FaceColor', [0.9,0.9,1], 'EdgeColor', 'none'); 
    h1 = plot(R(:,i), 'b');
    h3 = plot(R_true(:,i), 'r');
        
    pos = get(gca, 'Position');
    pos(1) = x;
    pos(2) = y;
    pos(3) = widthXReward;
    pos(4) = heightYReward;
    set(gca, 'Position', pos);
    ylim(yLimCon);
    
    x = x + ((-1)^(i-1))*(widthXReward+marginXReward);
    
    if i==2
        y = y - heightYReward - marginYReward;
    end
        
    xlabel('iteration');
    ylabel('return');
    title(strcat('segment: ',{' '},num2str(i)));
end    

legend([h1 h2 h3], 'reward model return', 'std reward model return', 'true return',...
    'location', 'southeast');
    

savefig('+output/advancedx/convergence_multi_noise');
print('+output/advancedx/convergence_multi_noise', '-depsc');

close all;

%%

op.print_reward();
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
      
    if i==2
        hold on;
        scatter3(0.3, 0.6, max(max(children(4).ZData)), VPMarkerSize, 'Marker', VPMarkerType, ...
    'LineWidth', VPMarkerEdge, 'MarkerEdgeColor', VPMarkerEdgeColor, ...
    'MarkerFaceColor', VPMarkerFaceColor);
    end
    
    if i==4
        
        yPlane = min(min(children(4).YData)):0.01:max(max(children(4).YData));
        xPlane = 0.5*ones(1, length(yPlane));
        zPlane = max(max(children(4).ZData))*ones(1, length(yPlane));
        hold on;
        plot3(xPlane, yPlane, zPlane, 'k', 'LineWidth', 1, 'LineStyle', '--');     
    end
    
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

suptitle('Multi segment reward model');
    
savefig('+output/advancedx/return_flat_multi_noise');
print('+output/advancedx/return_flat_multi_noise', '-depsc');

close all;
