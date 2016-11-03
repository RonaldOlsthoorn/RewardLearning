function [mPost, sPost] = gp_lin(x_sam, y_sam, x_pred, hyp)
exportFigs = 0; % Do we export figures? 0 for no, 1 (or anything else) for yes.
useColor = 1; % Should we set up plots for colored output (1) or black-and-white output (0)?

lf = hyp.cov(1);
lx = hyp.cov(1);
sfm = hyp.cov(2);

Xm = x_sam;
fmh = y_sam';

Xs = x_pred;

%% Figure 2.6.
disp('Creating Figure 2.6.');
% We define data.

% We now set up the (squared exponential) covariance matrix and related terms.
nm = size(Xm,2); % This is the number of measurement points.
ns = size(Xs,2); % This is the number of trial points.
X = [Xm,Xs]; % We merge the measurement and trial points.
n = size(X,2); % This is the number of points.
diff = repmat(X,n,1) - repmat(X',1,n); % This is matrix containing differences between input points.
K = lf^2*exp(-1/2*diff.^2/lx^2); % This is the covariance matrix. It contains the covariances of each combination of points.
Kmm = K(1:nm,1:nm);
Kms = K(1:nm,nm+1:end);
Ksm = Kms';
Kss = K(nm+1:end,nm+1:end);
Sfm = sfm^2*eye(nm); % This is the noise covariance matrix.
mm = zeros(nm,1); % This is the mean vector m(Xm). We assume a zero mean function.
ms = zeros(ns,1); % This is the mean vector m(Xs). We assume a zero mean function.

% Next, we apply GP regression.
mPost = ms + Ksm/(Kmm + Sfm)*(fmh - mm); % This is the posterior mean vector.
SPost = Kss - Ksm/(Kmm + Sfm)*Kms; % This is the posterior covariance matrix.
sPost = sqrt(diag(SPost)); % These are the posterior standard deviations.

% We set up the GP plot.
figure(6);
clf(6);
hold on;
grid on;
xlabel('Input');
ylabel('Output');
if useColor == 0
	patch([Xs, fliplr(Xs)],[mPost-2*sPost; flipud(mPost+2*sPost)], 1, 'FaceColor', [1,1,1]*0.9, 'EdgeColor', 'none'); % This is the grey area in the plot.
	patch([Xs, fliplr(Xs)],[mPost-sPost; flipud(mPost+sPost)], 1, 'FaceColor', [1,1,1]*0.8, 'EdgeColor', 'none'); % This is the grey area in the plot.
	set(gca, 'layer', 'top'); % We make sure that the grid lines and axes are above the grey area.
	plot(Xs, mPost, 'k-', 'LineWidth', 1); % We plot the mean line.
	plot(Xm, fmh, 'ko'); % We plot the measurement points.
else
	patch([Xs, fliplr(Xs)],[mPost-2*sPost; flipud(mPost+2*sPost)], 1, 'FaceColor', [0.9,0.9,1], 'EdgeColor', 'none'); % This is the grey area in the plot.
	patch([Xs, fliplr(Xs)],[mPost-sPost; flipud(mPost+sPost)], 1, 'FaceColor', [0.8,0.8,1], 'EdgeColor', 'none'); % This is the grey area in the plot.
	set(gca, 'layer', 'top'); % We make sure that the grid lines and axes are above the grey area.
	plot(Xs, mPost, 'b-', 'LineWidth', 1); % We plot the mean line.
    
	plot(Xm, fmh, 'ro'); % We plot the measurement points.
end
axis([0,4,-1.5,2.5]);
if exportFigs ~= 0
	export_fig('NoisyGPRegression.png','-transparent');
end

end