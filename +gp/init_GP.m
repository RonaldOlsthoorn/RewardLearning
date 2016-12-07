function obj = init_GP(gp_par)
% Factory function for gp objects

obj = gp.GP();
obj.hyp = gp_par.hyp;

obj.mean = str2func(strcat('gp.mean.', gp_par.mean));

switch gp_par.cov
    case 'squared_exponential'
        obj.cov = gp.cov.squared_exponential();
    case 'quadratic'
        obj.cov = gp.cov.quadratic();
    otherwise
        obj.cov = [];
end

obj.batch_rollouts = db.RolloutBatch();

obj.reset_figure();
end