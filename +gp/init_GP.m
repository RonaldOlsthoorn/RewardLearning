function obj = init_GP(gp_par)
% Factory function for gp objects

obj = gp.GP();
obj.hyp = gp_par.hyp;
obj.likfunc = gp_par.likfunc;
obj.covfunc = gp_par.covfunc;
obj.meanfunc = gp_par.meanfunc;

obj.batch_rollouts = db.RolloutBatch();

obj.reset_figure();
end