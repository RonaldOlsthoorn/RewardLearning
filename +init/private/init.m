function [ S, S_eval, dmp_par, forward_par, forward_par_eval, sim_par, rm ] = init( p )
% returns several structs used in the algorithm.
% S: reusable struct that contains new rollouts which are drawn every
% iteration
% S_eval: reusable struct containing an evaluation rollout, which is 
% basically a roll-out without exploration noise.
% ro_par: struct that contains parameters necessary for sampling batches 
% of normal rollouts.
% ro_par_eval: duplication of ro_par containing parameters for the
% evaluation roll-outs.
% sim_par: struct containing all the parameters needed for simulation.
% rm: struct containing the reward model paramters.

% use static random seed
rng(10);

% roll out parameters
dmp_par.start        = p.start;
dmp_par.goal         = p.goal;
dmp_par.duration     = p.duration;
dmp_par.Ts           = p.Ts;
dmp_par.n_dmp_bf     = p.n_dmp_bf;

forward_par.forward_method = str2func(strcat('forward.update_', p.forward_method));
forward_par.std      = p.std;
forward_par.annealer = p.annealer;
forward_par.n_reuse  = p.n_reuse;
forward_par.reps     = p.reps;
forward_par.n_dmp_bf = p.n_dmp_bf;
forward_par.noise_mult   = 1;

forward_par_eval         = forward_par;
forward_par_eval.reps    = 1;     % only one repetition for evaluation
forward_par_eval.std     = 0;     
forward_par_eval.n_reuse = 0;

% simulation parameters
sim_par.wrapflag     = 0;
sim_par.arm         = read_par;
sim_par.controller  = str2func(strcat('controllers.', p.controller));
sim_par.Ts          = p.Ts;

% reward model parameters
rm.loss_tol     = p.loss_tol;
rm.improve_tol  = p.improve_tol;
rm.af           = str2func(strcat('acquisition.', p.af));
rm.rating_noise = p.rating_noise;
rm.n_segments   = p.n_segments;
rm.n_ff         = 2;
rm.meanfunc     = [];
rm.covfunc      = @covSEard; 
rm.likfunc      = @likGauss;

S.t             = 0:p.Ts:(p.duration-p.Ts); % time vector
S.n_end         = length(S.t);              % length of total simulation
S.ref = p.ref;

% initialize the reference, if used.
if ~strcmp('none', p.ref)
    ref_function    = str2func(strcat('refs.', p.ref));
    S.ref           = ref_function(dmp_par);
end

S_eval         = S;     % used for noiseless cost assessment

[ S, S_eval ] = init_dmps( S, S_eval, dmp_par );

rm = init_rm(S, rm);
rm.outcome_handles = init_outcome_handles(rm);

end