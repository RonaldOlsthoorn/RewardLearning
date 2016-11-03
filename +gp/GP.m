classdef GP < handle
    %GP simple class used as a wrapper for the gpml library
    
    properties(Constant)
        
        figID = 6;
    end
    
    properties
        
        hyp;
        likfunc;
        covfunc;
        meanfunc;
        batch_rollouts;
        outcomes = [];
        ratings = [];
    end
    
    methods
        
        function add_demonstration(obj, demonstration)
            
            obj.batch_rollouts.append_rollout(demonstration);
            
            obj.extract_gp_points();
            
            %             nlml = gp(obj.hyp, @infExact, ...
            %                 obj.meanfunc, obj.covfunc, obj.likfunc,...
            %                 obj.outcomes, obj.ratings);
            %
            %             obj.hyp = minimize(obj.hyp, @gp, -100, @infExact, ...
            %                 obj.meanfunc, obj.covfunc, obj.likfunc, ...
            %                 obj.outcomes, obj.ratings);
        end
        
        function add_batch_demonstrations(obj, batch_demonstrations)
            
            obj.batch_rollouts.append_batch(batch_demonstrations);
            
            obj.extract_gp_points();
            
            %             nlml = gp(obj.hyp, @infExact, ...
            %                 obj.meanfunc, obj.covfunc, obj.likfunc,...
            %                 obj.outcomes, obj.ratings);
            
            %             obj.hyp = minimize(obj.hyp, @gp, -100, @infExact, ...
            %                 obj.meanfunc, obj.covfunc, obj.likfunc, ...
            %                 obj.outcomes, obj.ratings);
        end
        
        function remove_demonstration(obj, demonstration)
            
            obj.batch_rollouts.delete(demonstration);
            
            obj.extract_gp_points();
            
            %             obj.hyp = minimize(obj.hyp, @gp, -100, @infExact, ...
            %                 obj.meanfunc, obj.covfunc, obj.likfunc, ...
            %                 obj.outcomes, obj.ratings);
        end
        
        function [reward, s2] = interpolate_rollout(obj, rollout)
            
            [reward, s2] = obj.interpolate(rollout.sum_out);
        end
        
        function [reward, s2] = interpolate(obj, outcomes)
            
            lf = obj.hyp.cov(1);
            lx = obj.hyp.cov(2);
            sfm = obj.hyp.lik(1);
            
            Xm = obj.outcomes';
            fmh = obj.ratings;
            
            Xs = outcomes';
            
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
            
            reward = mPost;
            s2 = sPost;
        end
        
        function print(obj)
            
            minx = min(obj.outcomes);
            maxx = max(obj.outcomes);
            dx = (maxx-minx);
            
            x_grid = ((minx-dx):(dx/100):(maxx+dx))';
            
            [mPost, sPost] = obj.interpolate(x_grid);
            
            figure(obj.figID);
            clf;
            hold on;
            grid on;
            
            patch([x_grid; flip(x_grid)], [mPost-2*sPost; flipud(mPost+2*sPost)], 1, 'FaceColor', [0.9,0.9,1], 'EdgeColor', 'none'); % This is the grey area in the plot.
            patch([x_grid; flip(x_grid)],[mPost-sPost; flipud(mPost+sPost)], 1, 'FaceColor', [0.8,0.8,1], 'EdgeColor', 'none'); % This is the grey area in the plot.
            set(gca, 'layer', 'top'); % We make sure that the grid lines and axes are above the grey area.
            plot(x_grid, mPost, 'b-', 'LineWidth', 1); % We plot the mean line.      
            plot(obj.outcomes, obj.ratings, 'ro'); % We plot the measurement points.
        end
        
        function extract_gp_points(obj)
            
            obj.outcomes = zeros(obj.batch_rollouts.size, 1);
            obj.ratings = zeros(obj.batch_rollouts.size, 1);
            
            for i = 1:obj.batch_rollouts.size
                
                obj.outcomes(i, :) = obj.batch_rollouts.get_rollout(i).sum_out;
                obj.ratings(i, :) = obj.batch_rollouts.get_rollout(i).R_expert;
            end
        end
        
        function minimize(obj)
            
            obj.hyp = minimize(obj.hyp, @gp, -100, @infExact, ...
                obj.meanfunc, obj.covfunc, obj.likfunc, ...
                obj.outcomes, obj.ratings);
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

