classdef GP < handle
    %GP simple class used as a wrapper for the gpml library
    
    properties
        
        hyp;
        likfunc;
        covfunc;
        meanfunc;
        batch_rollouts = db.RolloutBatch();
        outcomes = [];
        ratings = [];
    end
    
    methods
        
        function obj = GP(gp_par)
            
            obj.hyp = gp_par.hyp;
            obj.likfunc = gp_par.likfunc;
            obj.covfunc = gp_par.covfunc;
            obj.meanfunc = gp_par.meanfunc;
        end
        
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
            
            [reward, s2] = gp(obj.hyp, @infExact, ...
                obj.meanfunc, obj.covfunc, obj.likfunc,...
                obj.outcomes, obj.ratings, ...
                outcomes);
        end
        
        function print(obj)
            
            x_grid = (-1:0.01:0)';
            [m, s2] = obj.interpolate(x_grid);
            f = [m+2*sqrt(s2); flipdim(m-2*sqrt(s2),1)];
            
            figure;
            hold on;
            fill([x_grid; flipdim(x_grid,1)], f, [7 7 7]/8);
            plot(x_grid, m)
            plot(obj.outcomes, obj.ratings, ...
                '+', 'MarkerSize', 10, 'Color',[0,0.7,0.9]);
            
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
        
    end
end

