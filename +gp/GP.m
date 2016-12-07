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
    end
    
    methods
        
        function [reward, s2] = assess(obj, x_infer)
            
            sfm = obj.hyp.lik(1);
            
            Xm = obj.x_measured';
            fmh = obj.y_measured;
            
            Xs = x_infer';
            
            % We now set up the (squared exponential) covariance matrix and related terms.
            nm = size(Xm,2); % This is the number of measurement points.
            X = [Xm,Xs]; % We merge the measurement and trial points.
            
            K = obj.cov.k(X, obj.hyp.cov);
            
            %             n = size(X,2); % This is the number of points.
            %             diff = repmat(X,n,1) - repmat(X',1,n); % This is matrix containing differences between input points.
            %             K = lf^2*exp(-1/2*diff.^2/lx^2); % This is the covariance matrix. It contains the covariances of each combination of points.
            
            Kmm = K(1:nm,1:nm);
            Kms = K(1:nm,nm+1:end);
            Ksm = Kms';
            Kss = K(nm+1:end,nm+1:end);
            Sfm = sfm^2*eye(nm); % This is the noise covariance matrix.
            
            mm = obj.mean(Xm, obj.hyp.mean);
            ms = obj.mean(Xs, obj.hyp.mean);
            
            % mm = zeros(nm,1); % This is the mean vector m(Xm). We assume a zero mean function.
            % ms = zeros(ns,1); % This is the mean vector m(Xs). We assume a zero mean function.
            
            % Next, we apply GP regression.
            mPost = ms' + Ksm/(Kmm + Sfm)*(fmh - mm'); % This is the posterior mean vector.
            SPost = Kss - Ksm/(Kmm + Sfm)*Kms; % This is the posterior covariance matrix.
            sPost = sqrt(diag(SPost)); % These are the posterior standard deviations.
            
            reward = mPost;
            s2 = sPost;
        end
        
        function logp = minimize(obj, hyp0)
            
            nm = length(obj.x_measured(1,:)); % This is the number of measurements we will do.
            
            % We take nm random input points and, according to the GP distribution, we randomly sample output values from it.
            Xm = obj.x_measured;                       
            fmh = obj.y_measured;
            
            h = hyp0; 
            
            % We set things up for the gradient ascent algorithm.
            numSteps = 100;
            stepSize = 1;
            stepSizeFactor = 2; 
            maxReductions = 100; 
            clear logp; 
            newHypDeriv = zeros(3,1); 
            
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
                        newHyp = hyp0;
                    else
                        newHyp.cov = h.cov-stepSize.*hypDeriv.cov; % We apply a normal ass gradient descent.
                    end
                    % Now we check the new hyperparameters. If they are good, we will implement them.
                    if min(newHyp > 0) % The parameters have to remain positive. If they are not, something is wrong. To be precise, the step size is too big.
                        % We partly implement the new hyperparameters and check the new value of logp.

                        Sfm = newHyp.lik^2*eye(nm); % This is the noise covariance matrix.       
                        Kmm = obj.cov.k(Xm, newHyp.cov);

                        P = Kmm + Sfm;
                        mb = (ones(nm,1)'/P*fmh)/(ones(nm,1)'/P*ones(nm,1)); % This is the (constant) mean function m(x) = \bar{m}. You can get rid of this line if you don't want to tune \bar{m}.
                        am = (Xm'/P*fmh)/(Xm'/P*Xm);
                        newLogp = -nm/2*log(2*pi) - 1/2*logdet(P) - 1/2*(fmh - mb)'/P*(fmh - mb);
                        % If this is the first time we are in this loop, or if the new logp is better than the old one, we fully implement the new hyperparameters and recalculate the derivative.
                        if ~exist('logp','var') || newLogp >= logp
                            % We calculate the new hyperparameter derivative.
                            alpha = P\(fmh - mb);
                            R = alpha*alpha' - inv(P);
                            
                            newHypDeriv(1) = 1/2*trace(R*obj.cov.dkdlf);
                            newHypDeriv(2) = 1/2*trace(R*obj.cov.dkdlx);
                            newHypDeriv(end) = 1/2*trace(R);
                            
                            % If this is not the first time we run this, we also update the step size, based on how much the (normalized) derivative direction has changed. If the derivative is still in the
                            % same direction as earlier, we take a bigger step size. If the derivative is in the opposite direction, we take a smaller step size. And if the derivative is perpendicular to
                            % what is used to be, then the step size was perfect and we keep it. For this scheme, we use the dot product.
                            if exist('logp','var')
                                directionConsistency = ((hypDeriv.*newHyp)'*(newHypDeriv.*newHyp))/norm(hypDeriv.*newHyp)/norm(newHypDeriv.*newHyp);
                                stepSize = stepSize*stepSizeFactor^directionConsistency;
                            end
                            break; % We exit the step-size-reduction loop.
                        end
                    end
                    % If we reach this, it means the hyperparameters we tried were not suitable. In this case, we should reduce the step size and try again. If the step size is small enough, there will
                    % always be an improvement of the hyperparameters. (Unless they are fully perfect, which never really occurs.)
                    stepSize = stepSize/stepSizeFactor;
                end
                % We update the important parameters.
                h = newHyp;
                logp = newLogp;
                
                obj.hyp = h;
            end
        end
        
        function vec = hyper_to_vector(hyp)
            
            vec = [hyp.cov; hyp.lik];
        end
        
        function hyp = vector_to_hyp(vec)
            
            hyp.cov = vec(1:(end-1));
            hyp.lik = vec(end);
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

