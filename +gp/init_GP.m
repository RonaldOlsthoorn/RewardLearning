function obj = init_GP(gp_par)
% Factory function for gp objects
% TODO: REMOVE CASES. WE DO NOT USE THEM!!

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

switch gp_par.mean
    case 'zero'
        obj.mean = gp.mean.zero();
    case 'constant'
        obj.mean = gp.mean.constant();
    case 'linear'
        obj.mean = gp.mean.lin();
    case 'affine'
        obj.mean = gp.mean.affine();
    otherwise
        obj.mean = [];
end

obj.batch_rollouts = db.RolloutBatch();
obj.reset_figure();
end