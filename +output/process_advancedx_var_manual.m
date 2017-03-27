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
PPMarkerEdgeColor = 'r';
PPMarkerFaceColor = 'w';

%%
load('+output/manual/viapoint_advancedx_var_single_manual');
op = output.Output.from_struct(res_struct);
op.print();

time = op.Reward_trace(end).time;
t_plane = time(600:end);
plane = 0.5*ones(1,length(t_plane));

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
children = get(gca, 'Children');
delete(children(4));

x = x+widthX+marginX;

subplot(1,3,2);
pos = get(gca, 'Position');
pos(1) = x;
pos(2) = marginY;
pos(3) = widthX;
pos(4) = heightY;
set(gca, 'Position', pos);
children = get(gca, 'Children');
delete(children(4));

x = x+widthX+marginX;

subplot(1,3,3);
pos = get(gca, 'Position');
pos(1) = x;
pos(2) = marginY;
pos(3) = widthX;
pos(4) = heightY;
set(gca, 'Position', pos);
children = get(gca, 'Children');
delete(children(4));

suptitle('Resulting trajectory')

legend([children(3) children(1) children(2)], ...
    'Final rollout', 'Reference viapoint', 'Final rollout viapoint', ...
        'location', 'southwest');

savefig('+output/advancedx-var/trajectory_single_manual');
print('+output/advancedx-var/trajectory_single_manual', '-depsc');

%%

figure(3);

xlabel('iteration');
ylabel('return');

children = get(gca, 'Children');

title('Convergence');

legend([children(1) children(2)], ...
    'reward model return', 'expert return',...
        'location', 'southeast');
    
savefig('+output/advancedx-var/convergence_single_manual');
print('+output/advancedx-var/convergence_single_manual', '-depsc');

close all;

%%
load('+output/manual/viapoint_advancedx_var_multi_manual');
op = output.Output.from_struct(res_struct);
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
children = get(gca, 'Children');
delete(children(4));

x = x+widthX+marginX;

subplot(1,3,2);
pos = get(gca, 'Position');
pos(1) = x;
pos(2) = marginY;
pos(3) = widthX;
pos(4) = heightY;
set(gca, 'Position', pos);
children = get(gca, 'Children');
delete(children(4));

x = x+widthX+marginX;

subplot(1,3,3);
pos = get(gca, 'Position');
pos(1) = x;
pos(2) = marginY;
pos(3) = widthX;
pos(4) = heightY;
set(gca, 'Position', pos);
children = get(gca, 'Children');
delete(children(4));

children = get(gca, 'Children');

suptitle('Resulting trajectory')

legend([ children(3) children(1) children(2)], ...
    'Final rollout', 'Reference viapoint', 'Final rollout viapoint', ...
        'location', 'southwest');


savefig('+output/advancedx-var/trajectory_multi_manual');
print('+output/advancedx-var/trajectory_multi_manual', '-depsc');

%%

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


%%

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
        scatter3(0.3, 0.6, max(max(children(4).ZData)),  VPMarkerSize, 'Marker', VPMarkerType, ...
    'LineWidth', VPMarkerEdge, 'MarkerEdgeColor', VPMarkerEdgeColor, ...
    'MarkerFaceColor', VPMarkerFaceColor);
    end
    
%     if i==4
%         
%         yPlane = min(min(children(4).YData)):0.01:max(max(children(4).YData));
%         xPlane = 0.5*ones(1, length(yPlane));
%         zPlane = max(max(children(4).ZData))*ones(1, length(yPlane));
%         hold on;
%         plot3(xPlane, yPlane, zPlane, 'k', 'LineWidth', 1)     
%     end
    
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

suptitle('Multi segment reward function');
    
savefig('+output/advancedx-var/return_flat_multi_manual');
print('+output/advancedx-var/return_flat_multi_manual', '-depsc');

close all; clear; clc;
