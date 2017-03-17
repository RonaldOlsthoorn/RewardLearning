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
load('+output/viapoint_advancedx_var_single');
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
    
savefig('+output/advancedx-var/trajectory_single_noise');
print('+output/advancedx-var/trajectory_single_noise', '-depsc');

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
patch([it, fliplr(it)],[(R+R_var); flipud((R-R_var))], 1, ...
     'FaceColor', [0.9,0.9,1], 'EdgeColor', 'none'); 
plot(R, 'b');
plot(R_true, 'r');

xlabel('iteration');
ylabel('return noiseless rollout');

title('Return convergence');

% legend([children(1) children(2)], ...
%     'reward model return', 'true return',...
%         'location', 'southeast');
    
    
savefig('+output/advancedx-var/convergence_single_noise');
print('+output/advancedx-var/convergence_single_noise', '-depsc');

close all;

%%
load('+output/viapoint_advancedx_var_multi');
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

savefig('+output/advancedx-var/trajectory_multi_noise');
print('+output/advancedx-var/trajectory_multi_noise', '-depsc');

close all

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

%suptitle('Return convergence');
    
x = marginXReward;
y = 2*marginYReward+heightYReward;

for i = 1:4
    
    subplot(2,2,i);
    hold on;
    patch([it, fliplr(it)],[(R(:,i)+R_var(:,i)); flipud((R(:,i)-R_var(:,i)))], 1, ...
     'FaceColor', [0.9,0.9,1], 'EdgeColor', 'none'); 
    h1 = plot(R(:,i), 'b');
    h2 = plot(R_true(:,i), 'r');
            
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
    
savefig('+output/advancedx-var/convergence_multi_noise');
print('+output/advancedx-var/convergence_multi_noise', '-depsc');

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

savefig('+output/advancedx-var/return_flat_multi_noise');
print('+output/advancedx-var/return_flat_multi_noise', '-depsc');

close all;