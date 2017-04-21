close all; clear all; clc;

gp = GP();

gp.cov = cov.squared_exponential;
gp.mean = mean.zero;

gp.hyp.cov = [5; 3];
gp.hyp.mean = [];
gp.hyp.lik = 0.4;

gp.x_measured = [1; 2; 3];
gp.y_measured = [-15.6; -9.1; -3.5] + 30;

figID = figure;
gp.print(figID);

xlabel('phi');
ylabel('Return');

c = get(gca, 'Children');
legend([c(2), c(3), c(1)], 'Mean function', 'Variance', ...
    'Rated demonstrations', 'Location', 'southeast')


gp.x_measured = [1; 2; 3; 4];
gp.y_measured = [-15.6; -9.1; -3.5; -4] + 30;

figID2 = figure;
gp.print(figID2);

set(gca, 'xlim', [-1 5]);
set(gca, 'ylim', [-5 35]);

xlabel('phi');
ylabel('Return');

c = get(gca, 'Children');
legend([c(2), c(3), c(1)], 'Mean function', 'Variance', ...
    'Rated demonstrations', 'Location', 'southeast')
