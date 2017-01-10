classdef GP < handle
    %Gaussian Process class.
    
    properties(Constant)
        
        figID = 6;
    end
    
    properties
        
        hyp;
        lik;
        cov;
        mean;
        batch_rollouts;
        x_measured = [];
        y_measured = [];
        phi_measured = [];
    end
    
    methods
        
        function [reward, s2] = assess(obj, x_infer)
            
            sfm = obj.hyp.lik(1);
            
            Xm = obj.x_measured';
            fmh = obj.y_measured;
            
            Xs = x_infer';
            Phi_s = obj.gp_features(Xs);
            Phi_m = obj.phi_measured;
            
            % We now set up the (squared exponential) covariance matrix and related terms.
            nm = size(Xm,2); % This is the number of measurement points.
            X = [Xm,Xs]; % We merge the measurement and trial points.
            
            Phi = [Phi_m, Phi_s];
            
            K = obj.cov.k(Phi, obj.hyp.cov);
            
            % n = size(X,2); % This is the number of points.
            % diff = repmat(X,n,1) - repmat(X',1,n); % This is matrix containing differences between input points.
            % K = lf^2*exp(-1/2*diff.^2/lx^2); % This is the covariance matrix. It contains the covariances of each combination of points.
            
            Kmm = K(1:nm,1:nm);
            Kms = K(1:nm,nm+1:end);
            Ksm = Kms';
            Kss = K(nm+1:end,nm+1:end);
            Sfm = sfm^2*eye(nm); % This is the noise covariance matrix.
            
            mm = obj.mean.m(Xm, obj.hyp.mean);
            ms = obj.mean.m(Xs, obj.hyp.mean);
            
            % mm = zeros(nm,1); % This is the mean vector m(Xm). We assume a zero mean function.
            % ms = zeros(ns,1); % This is the mean vector m(Xs). We assume a zero mean function.
            
            mPost = ms + Ksm/(Kmm + Sfm)*(fmh - mm); % This is the posterior mean vector.
            SPost = Kss - Ksm/(Kmm + Sfm)*Kms; % This is the posterior covariance matrix.
            sPost = sqrt(diag(SPost)); % These are the posterior standard deviations.
            
            Kw = diag(obj.hyp.cov);
            
            % We calculate the posterior distribution of w.
            muw = (Phi_m/Sfm*Phi_m' + inv(Kw))\Phi_m/Sfm*fmh;
            Sw = inv(Phi_m/Sfm*Phi_m' + inv(Kw));
            
            reward = mPost;
            s2 = real(sPost);
        end
        
        function compute_features_measurements(obj)
            
            Xm = obj.x_measured';
            Phi_m = obj.gp_features(Xm);
            obj.phi_measured = Phi_m;
        end
        
        function Phi = gp_features(~, X)
           
            [d, nm]  = size(X);

            Phi = zeros((d*(d+1)/2)+d+1, nm);
                        
            index = 1;
            k = 1;
            
            while k <= d
                Phi(index,:) = X(k,:);
                index = index + 1;
                for i = k:d
                    Phi(index,:) = X(k,:).*X(i,:);
                    index = index + 1;
                end
                k = k + 1;
            end
            
            Phi(end,:) = ones(1,nm);
                    
        end
        
        function logp = minimize(obj)
            
            %logp = obj.minimize_hypers(obj.hyp);
            logp = obj.minimize_sigma();
        end
        
        function logp = minimize_sigma(obj)
            
            nm = length(obj.x_measured(:,1)); % This is the number of measurements we will do.
            
            % We take nm random input points and, according to the GP distribution, we randomly sample output values from it.
            Xm = obj.x_measured';                       
            fm = obj.y_measured;
            
            Phi_m = obj.phi_measured;
                        
            hCov = obj.hyp.cov;
            hMean = obj.hyp.mean;
            hLik = obj.hyp.lik;
            
            % We set things up for the gradient ascent algorithm.
            numSteps = 100;
            stepSizeLik = hLik/10 ;
            
            stepSizeFactor = 2; 
            maxReductions = 100; 
            
            newHypLikDeriv = zeros(length(hLik),1);
                      
            % Now we can start iterating
            for i = 1:numSteps
                % We try to improve the parameters, all the while checking the step size.
                for j = 1:maxReductions
                    % We check if we haven't accidentally been decreasing the step size too much.
                    if j == maxReductions
                        disp('Error: something is wrong with the step size in the hyperparameter optimization scheme.');
                    end
                    % We calculate new hyperparameters. Or at least, candidates. We still check them.
                    if ~exist('logp','var') % If no logp is defined, this is the first time we are looping. In this case, with no derivative data known yet either, we keep the hyperparameters the same.
                        newHypLik = obj.hyp.lik';                       
                    else
                        % We apply a normal ass gradient descent.
                        newHypLik = hLik+stepSizeLik.*newHypLikDeriv;
                    end
                    
                    % Now we check the new hyperparameters. If they are good, we will implement them.
                    if min(newHypLik) > 0 % The parameters have to remain positive. 
                        %If they are not, something is wrong. To be precise, the step size is too big.
                        % We partly implement the new hyperparameters and check the new value of logp.

                        Sfm = newHypLik^2*eye(nm); % This is the noise covariance matrix.       
                        Kmm = obj.cov.k(Phi_m, hCov);

                        P = Kmm + Sfm;
                        
                        % optimize mean
                        mm = obj.mean.m(Phi_m, hMean);
                        
                        newLogp = -nm/2*log(2*pi) - 1/2*tools.logdet(P) - 1/2*(fm - mm)'/P*(fm - mm);
                        % If this is the first time we are in this loop, 
                        % or if the new logp is better than the old one, 
                        % we fully implement the new hyperparameters and recalculate the derivative.
                        if ~exist('logp','var') || newLogp >= logp
                            % We calculate the new hyperparameter derivative.
                            
                            alpha = P\(fm - mm);
                            R = alpha*alpha' - inv(P);
                            
                            newHypLikDeriv = newHypLik*trace(R);
                            
                            % If this is not the first time we run this, we also update the step size, based on how much the (normalized) derivative direction has changed. If the derivative is still in the
                            % same direction as earlier, we take a bigger step size. If the derivative is in the opposite direction, we take a smaller step size. And if the derivative is perpendicular to
                            % what is used to be, then the step size was perfect and we keep it. For this scheme, we use the dot product.
                            if exist('logp','var')
                                                                
                                directionConsistencyLik = ((hypLikDeriv.*newHypLik)'*...
                                    (newHypLikDeriv.*newHypLik))/norm(hypLikDeriv.*newHypLik)/...
                                    norm(newHypLikDeriv.*newHypLik);
                                stepSizeLik = stepSizeLik*stepSizeFactor^directionConsistencyLik;       
                            end
                            break; % We exit the step-size-reduction loop.
                        end
                    end
                    % If we reach this, it means the hyperparameters we tried were not suitable. In this case, we should reduce the step size and try again. If the step size is small enough, there will
                    % always be an improvement of the hyperparameters. (Unless they are fully perfect, which never really occurs.)
                    stepSizeLik = stepSizeLik/stepSizeFactor;
                end
                % We update the important parameters.
                logp = newLogp;

                hLik = newHypLik;   
                hypLikDeriv = newHypLikDeriv;
                
            end
            
            obj.hyp.lik =hLik;   
            
        end
        
        function logp = minimize_hypers(obj, hyp0)
            
            nm = length(obj.x_measured(:,1)); % This is the number of measurements we will do.
            
            % We take nm random input points and, according to the GP distribution, we randomly sample output values from it.
            Xm = obj.x_measured';                       
            fm = obj.y_measured;
                        
            hCov = hyp0.cov';
            hMean = hyp0.mean';
            hLik = hyp0.lik;
            
            % We set things up for the gradient ascent algorithm.
            numSteps = 100;
            stepSizeCov = 1;
            stepSizeLik = 1;
            
            stepSizeFactor = 2; 
            maxReductions = 100; 
            clear logp; 
            
            newHypCovDeriv = zeros(length(hCov),1);
            newHypLikDeriv = zeros(length(hLik),1);
                      
            % Now we can start iterating
            for i = 1:numSteps
                % We try to improve the parameters, all the while checking the step size.
                for j = 1:maxReductions
                    % We check if we haven't accidentally been decreasing the step size too much.
                    if j == maxReductions
                        disp('Error: something is wrong with the step size in the hyperparameter optimization scheme.');
                    end
                    % We calculate new hyperparameters. Or at least, candidates. We still check them.
                    if ~exist('logp','var') % If no logp is defined, this is the first time we are looping. In this case, with no derivative data known yet either, we keep the hyperparameters the same.
                        newHypCov = hyp0.cov';
                        newHypLik = hyp0.lik';                       
                    else
                        % We apply a normal ass gradient descent.
                        newHypCov = hCov+stepSizeCov.*newHypCovDeriv; 
                        newHypLik = hLik+stepSizeLik.*newHypLikDeriv;
                    end
                    
                    % Now we check the new hyperparameters. If they are good, we will implement them.
                    if min(newHypCov) > 0 && min(newHypLik) > 0 % The parameters have to remain positive. 
                        %If they are not, something is wrong. To be precise, the step size is too big.
                        % We partly implement the new hyperparameters and check the new value of logp.

                        Sfm = newHypLik^2*eye(nm); % This is the noise covariance matrix.       
                        Kmm = obj.cov.k(Xm, newHypCov);

                        P = Kmm + Sfm;
                        
                        % optimize mean
                        newHypMean = obj.mean.optimize_hypers(P, Xm, fm);
                        mm = obj.mean.m(Xm, newHypMean);
                        
                        newLogp = -nm/2*log(2*pi) - 1/2*tools.logdet(P) - 1/2*(fm - mm)'/P*(fm - mm);
                        % If this is the first time we are in this loop, 
                        % or if the new logp is better than the old one, 
                        % we fully implement the new hyperparameters and recalculate the derivative.
                        if ~exist('logp','var') || newLogp >= logp
                            % We calculate the new hyperparameter derivative.
                            
                            alpha = P\(fm - mm);
                            R = alpha*alpha' - inv(P);
                            
                            newHypCovDeriv = obj.cov.deriv(R, Xm, newHypCov);
                            newHypLikDeriv = newHypLik*trace(R);
                            
                            % If this is not the first time we run this, we also update the step size, based on how much the (normalized) derivative direction has changed. If the derivative is still in the
                            % same direction as earlier, we take a bigger step size. If the derivative is in the opposite direction, we take a smaller step size. And if the derivative is perpendicular to
                            % what is used to be, then the step size was perfect and we keep it. For this scheme, we use the dot product.
                            if exist('logp','var')
                                
                                directionConsistencyCov = ((hypCovDeriv.*newHypCov)'*...
                                    (newHypCovDeriv.*newHypCov))/norm(hypCovDeriv.*newHypCov)/...
                                    norm(newHypCovDeriv.*newHypCov);
                                stepSizeCov = stepSizeCov*stepSizeFactor^directionConsistencyCov;
                                
                                directionConsistencyLik = ((hypLikDeriv.*newHypLik)'*...
                                    (newHypLikDeriv.*newHypLik))/norm(hypLikDeriv.*newHypLik)/...
                                    norm(newHypLikDeriv.*newHypLik);
                                stepSizeLik = stepSizeLik*stepSizeFactor^directionConsistencyLik;
                                
                            end
                            break; % We exit the step-size-reduction loop.
                        end
                    end
                    % If we reach this, it means the hyperparameters we tried were not suitable. In this case, we should reduce the step size and try again. If the step size is small enough, there will
                    % always be an improvement of the hyperparameters. (Unless they are fully perfect, which never really occurs.)
                    stepSizeCov = stepSizeCov/stepSizeFactor;
                    stepSizeLik = stepSizeLik/stepSizeFactor;
                end
                % We update the important parameters.
                logp = newLogp;
                
                hCov = newHypCov;
                hMean = newHypMean;
                hLik = newHypLik;   
                
                hypCovDeriv = newHypCovDeriv;
                hypLikDeriv = newHypLikDeriv;
            end
            
            obj.hyp.cov = hCov;
            obj.hyp.mean = hMean;
            obj.hyp.lik =hLik;   
        end
          
        function update_hyper_parameters(obj)
            
            obj.minimize(obj.hyp);
        end
        
        % print mean and covariance of the gp.
        function print(obj, figID)
            
            minx = min(obj.x_measured);
            maxx = max(obj.x_measured);
            dx = (maxx-minx);
            
            x_grid = ((minx-dx):(dx/100):(maxx+dx))';
            
            [mPost, sPost] = obj.assess(x_grid);
            
            figure(figID);
            clf;
            hold on;
            grid on;
            
            patch([x_grid; flip(x_grid)], [mPost-2*sPost; flipud(mPost+2*sPost)], 1, 'FaceColor', [0.9,0.9,1], 'EdgeColor', 'none'); % This is the grey area in the plot.
            patch([x_grid; flip(x_grid)],[mPost-sPost; flipud(mPost+sPost)], 1, 'FaceColor', [0.8,0.8,1], 'EdgeColor', 'none'); % This is the grey area in the plot.
            set(gca, 'layer', 'top'); % We make sure that the grid lines and axes are above the grey area.
            plot(x_grid, mPost, 'b-', 'LineWidth', 1); % We plot the mean line.
            plot(obj.x_measured, obj.y_measured, 'ro'); % We plot the measurement points.
        end
        
        function reset_figure(obj)
            figure(obj.figID);
            set(double(obj.figID),...
                'units','normalized','outerposition',[0 0 1 1]);
            clf;       
        end
        
        % Make a copy of a handle object.
        function new = copy(this)
            % Instantiate new object of the same class.
            new = gp.GP();
            
            % Copy all non-hidden properties.
            p = properties(this);
            for i = 1:length(p)
                if strcmp(p{i}, 'batch_rollouts')
                    new.(p{i}) = this.(p{i}).copy();
                elseif strcmp(p{i}, 'figID')
                else
                    new.(p{i}) = this.(p{i});
                end
            end
        end
    end
end

