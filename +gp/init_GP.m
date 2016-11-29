function obj = init_GP(gp_par)
% Factory function for gp objects

obj = gp.GP();
obj.hyp = gp_par.hyp;
obj.meanfunc = str2func(strcat('gp.mean.', gp_par.mean));
obj.meanfunc = str2func(strcat('gp.cov.', gp_par.mean));

obj.batch_rollouts = db.RolloutBatch();

obj.reset_figure();
end