function overlay_viaplane
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

t = 6:0.01:8;
x = 0.5*ones(1,length(t));
y = 0.3*ones(1,length(t));

figure(1)
subplot(1,3,1)
hold on;
plot(t, x, 'LineWidth', 2, 'Color', 'black')

subplot(1,3,2)
hold on;
plot(t, y, 'LineWidth', 2, 'Color', 'black')



end
