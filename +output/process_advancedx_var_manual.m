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
load('+output/viapoint_advancedx_var_single_manual');
op = output.Output.from_struct(to_save);
op.print();

figure(2);

% global
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
    
savefig('+output/advancedx-var/trajectory_single_manual');
print('+output/advancedx-var/trajectory_single_manual', '-depsc');

figure(3);

xlabel('iteration');
ylabel('return');

children = get(gca, 'Children');

title('Return convergence');

legend([children(1) children(2)], ...
    'reward model return', 'expert return',...
        'location', 'southeast');
    
savefig('+output/advancedx-var/convergence_single_manual');
print('+output/advancedx-var/convergence_single_manual', '-depsc');

close all;

%%
load('+output/viapoint_advancedx_var_multi_manual');
op = output.Output.from_struct(to_save);
op.print();

figure(2);

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

savefig('+output/advancedx-var/trajectory_multi_manual');
print('+output/advancedx-var/trajectory_multi_manual', '-depsc');

figure(4);
set(gcf,'WindowStyle','normal')
set(gcf, 'Position', posFigReward);
set(gcf, 'PaperPositionMode','auto');

%suptitle('Return convergence');
    
x = marginXReward;
y = 2*marginYReward+heightYReward;

for i = 1:4
    
    subplot(2,2,i);
        
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
    ylabel('return');
end    
   
savefig('+output/advancedx-var/convergence_multi_manual');
print('+output/advancedx-var/convergence_multi_manual', '-depsc');

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
        scatter(0.3, 0.6, 0,  VPMarkerSize, 'Marker', VPMarkerType, ...
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
    
savefig('+output/advancedx-var/return_flat_multi_manual');
print('+output/advancedx-var/return_flat_multi_manual', '-depsc');

close all;

%%

load('+output/viapoint_advancedx_var_single_manual');
to_save_single = to_save;

load('+output/viapoint_advancedx_var_multi_manual');
to_save_multi = to_save;

% Load saved figures
c=hgload('+output/advancedx-var/convergence_single_manual.fig');
k=hgload('+output/advancedx-var/convergence_multi_manual.fig');
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
l(1) = legend(h(1), 'reward model return', 'expert return',...
        'location', 'southeast');
xlabel('iteration');
ylabel('return');
title('single GP return convergence');


subplot(1,2,2)
l(2) = legend(h(2), 'reward model return', 'expert return',...
        'location', 'southeast');
xlabel('iteration');
ylabel('return');
title('multi GP return convergence');

suptitle('Return convergence')

savefig('+output/advancedx-var/convergence_combi_manual');
print('+output/advancedx-var/convergence_combi_manual', '-depsc');

close all;

%%

% % Load saved figures
% hgload('+output/advancedx/trajectory_single_noise.fig');
% c(1) = subplot(1,3,1);
% c(2) = subplot(1,3,2);
% c(3) = subplot(1,3,3);
% 
% k=hgload('+output/advancedx/trajectory_multi_noise.fig');
% k(1) = subplot(1,3,1);
% k(2) = subplot(1,3,2);
% k(3) = subplot(1,3,3);
% % Prepare subplots
% 
% figure
% set(gcf,'WindowStyle','normal')
% set(gcf, 'Position', posFig);
% set(gcf, 'PaperPositionMode','auto');
% 
% h(1)=subplot(2,3,1);
% xlabel('time [s]');
% ylabel('x end effector [m]');
% 
% pos = get(gca, 'Position');
% pos(1) = marginX;
% pos(2) = 2*marginYReward + heightYReward;
% pos(3) = widthXReward;
% pos(4) = heightYReward;
% set(gca, 'Position', pos);
% 
% h(2)=subplot(2,3,2);
% xlabel('time [s]');
% ylabel('y end effector [m]');
% 
% pos = get(gca, 'Position');
% pos(1) = 2*marginX + widthX;
% pos(2) = 2*marginYReward + heightYReward;
% pos(3) = widthXReward;
% pos(4) = heightYReward;
% set(gca, 'Position', pos);
% 
% h(3)=subplot(2,3,3);
% xlabel('x end effector [m]');
% ylabel('y end effector [m]');
% 
% pos = get(gca, 'Position');
% pos(1) = 3*marginX + 2*widthX;
% pos(2) = 2*marginYReward + heightYReward;
% pos(3) = widthXReward;
% pos(4) = heightYReward;
% set(gca, 'Position', pos);
% 
% h(4)=subplot(2,3,4);
% xlabel('time [s]');
% ylabel('x end effector [m]');
% 
% pos = get(gca, 'Position');
% pos(1) = marginX;
% pos(2) = marginYReward;
% pos(3) = widthXReward;
% pos(4) = heightYReward;
% set(gca, 'Position', pos);
% 
% h(5)=subplot(2,3,5);
% xlabel('time [s]');
% ylabel('y end effector [m]');
% 
% pos = get(gca, 'Position');
% pos(1) = 2*marginX + widthX;
% pos(2) = marginYReward;
% pos(3) = widthXReward;
% pos(4) = heightYReward;
% set(gca, 'Position', pos);
% 
% h(6)=subplot(2,3,6);
% xlabel('x end effector [m]');
% ylabel('y end effector [m]');
% 
% pos = get(gca, 'Position');
% pos(1) = 3*marginX + 2*widthX;
% pos(2) = marginYReward;
% pos(3) = widthXReward;
% pos(4) = heightYReward;
% set(gca, 'Position', pos);
% 
% % Paste figures on the subplots
% copyobj(allchild(get(c(1),'CurrentAxes')),h(1));
% copyobj(allchild(get(c(2),'CurrentAxes')),h(2));
% copyobj(allchild(get(c(3),'CurrentAxes')),h(3));
% 
% copyobj(allchild(get(k(1),'CurrentAxes')),h(4));
% copyobj(allchild(get(k(2),'CurrentAxes')),h(5));
% copyobj(allchild(get(k(3),'CurrentAxes')),h(6));
% % Add legends
% 
% subplot(2,3,3)
% l(1) = legend(h(1), 'reward model return', 'true return',...
%         'location', 'southeast');
% 
% 
% 
% subplot(2,3,6)
% l(2) = legend(h(2), 'reward model return', 'true return',...
%         'location', 'southeast');
% 
% 
% suptitle('Resulting trajectories')
% 
% savefig('+output/advancedx/trajectories_combi_noise');
% print('+output/advancedx/trajectories_combi_noise', '-depsc');

close all; clear; clc;
