clear; close all; clc

% test for gp hypers

[m_x, m_y] = meshgrid(0:5:100, 0:5:100);
z = zeros(length(m_x(:,1)),length(m_x(1,:)));
z_true = z;

% create random points

x_feed = [  0   50
    10  50
    20  50
    30  50
    40  50
    50  50
    60  50
    70  50
    80  50
    90  50
    100 50
    ];

y_feed = -100*ones(11,1);


hyp.cov = [1; 1; 0];
hyp.mean = [];
hyp.lik = log(0.1);

hyp = minimize(hyp, @gp, -100, @infExact, ...
    [], @covSEard, @likGauss, ...
    x_feed, y_feed);

for i = 1:length(m_x(:,1))
    for j = 1:length(m_y(:,1))
        
        [m, ~] = gp(hyp, @infExact, ...
            [], @covSEard, @likGauss,...
            x_feed, y_feed,...
            [m_x(i,j) m_y(i,j)]);
        
        z(i, j) = m;
        z_true(i, j) = query_expert([m_x(i,j) m_y(i,j)] , 0);
    end
end

fig = figure(1);
set (fig, 'Units', 'normalized', 'Position', [0,0,1,1]);

subplot(2,2,1)
scatter3(x_feed(:,1), x_feed(:,2), y_feed,'x', 'r');
hold on
xlabel('x');
ylabel('y');
zlabel('z');
mesh(m_x, m_y, z);


x_feed = [  50  0
            50  10
            50  20
            50  30
            50  40
            50  50
            50  60
            50  70
            50  80
            50  90
            50  100
    ];

hyp.cov = [1; 1; 0];
hyp.mean = [];
hyp.lik = log(0.1);

hyp = minimize(hyp, @gp, -100, @infExact, ...
    [], @covSEard, @likGauss, ...
    x_feed, y_feed);

for i = 1:length(m_x(:,1))
    for j = 1:length(m_y(:,1))
        
        [m, ~] = gp(hyp, @infExact, ...
            [], @covSEard, @likGauss,...
            x_feed, y_feed,...
            [m_x(i,j) m_y(i,j)]);
        
        z(i, j) = m;
        z_true(i, j) = query_expert([m_x(i,j) m_y(i,j)] , 0);
    end
end

subplot(2,2,2)
scatter3(x_feed(:,1), x_feed(:,2), y_feed,'x', 'r');
hold on
xlabel('x');
ylabel('y');
zlabel('z');
mesh(m_x, m_y, z);

x_feed = [  0   0
            10  10
            20  20
            30  30
            40  40
            50  50
            60  60
            70  70
            80  80
            90  90
            100 100
    ];

y_feed = -100*ones(11,1);

hyp.cov = [0; 0; 0];
hyp.mean = [];
hyp.lik = log(0.1);

hyp = minimize(hyp, @gp, -100, @infExact, ...
    [], @covSEard, @likGauss, ...
    x_feed, y_feed);

for i = 1:length(m_x(:,1))
    for j = 1:length(m_y(:,1))
        
        [m, ~] = gp(hyp, @infExact, ...
            [], @covSEard, @likGauss,...
            x_feed, y_feed,...
            [m_x(i,j) m_y(i,j)]);
        
        z(i, j) = m;
        z_true(i, j) = query_expert([m_x(i,j) m_y(i,j)] , 0);
    end
end

subplot(2,2,3)
scatter3(x_feed(:,1), x_feed(:,2), y_feed,'x', 'r');
hold on
xlabel('x');
ylabel('y');
zlabel('z');
mesh(m_x, m_y, z);
