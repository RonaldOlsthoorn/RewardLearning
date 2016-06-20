function [ S, S_eval, ro_par, ro_par_eval, sim_par, rm ] = init( p )
% create several structs and matrices used in the algorithm

% use static random seed
rng(10);

% roll out parameters
ro_par.start        = p.start;
ro_par.goal         = p.goal;
ro_par.duration     = p.duration;
ro_par.Ts           = p.Ts;
ro_par.std          = p.std;
ro_par.n_reuse      = p.n_reuse;
ro_par.reps         = p.reps;
ro_par.n_dmp_bf     = p.n_dmp_bf;
ro_par.noise_mult   = 1;

ro_par_eval         = ro_par;
ro_par_eval.reps    = 1;     % only one repetition for evaluation
ro_par_eval.std     = 0;     
ro_par_eval.n_reuse = 0;

% simulation parameters
sim_par.wrapflag     = 0;
sim_par.arm         = read_par;
sim_par.controller  = str2func(p.controller);
sim_par.Ts          = p.Ts;

% reward model parameters
rm.loss_tol     = p.loss_tol;
rm.improve_tol  = p.improve_tol;
rm.af           = str2func(p.af);
rm.rating_noise = p.rating_noise;
rm.n_reward_bf  = p.n_reward_bf;
rm.n_ff         = 2*rm.n_reward_bf+2;

rm.meanfunc = {@meanSum, {@meanLinear, @meanConst}}; 
rm.covfunc = @covSEard; 
rm.likfunc = @likGauss;
rm.hyp.cov = [zeros(rm.n_ff,1); 0]; 
rm.hyp.mean = [ones(rm.n_ff,1); 1];
rm.hyp.lik = log(0.1);

global n_dmps

% S contains the roll out samples
S.t             = 0:p.Ts:(p.duration-p.Ts); % time vector
S.n_end         = length(S.t);              % length of total simulation
S.rollouts.dmp(1:n_dmps) = struct(...
    'xd',zeros(S.n_end,3),...                  % DMP desired state
    'bases',zeros(S.n_end,p.n_dmp_bf),...      % DMP bases function vector
    'eps',zeros(S.n_end,p.n_dmp_bf),...        % DMP noisy parameters
    'theta_eps',zeros(S.n_end,p.n_dmp_bf),...  % DMP noisy parameters+kernel weights
    'psi',zeros(S.n_end,p.n_dmp_bf));          % DMP Gaussian kernels

S.rollouts.q        = zeros(S.n_end,3);          % point mass pos
S.rollouts.u        = zeros(S.n_end,2*n_dmps);   % point mass command
S.rollouts.outcomes = zeros(S.n_end, rm.n_ff);
S.rollouts.r        = zeros(S.n_end, 1);
S.rollouts.R        = 0;



% initialize the reference, if used.
if strcmp('none', p.ref)
    S.ref = 'none';         % no reference function used in reward function
else
    ref_function    = str2func(p.ref);
    S.ref           = ref_function(ro_par);
end

S_eval         = S;     % used for noiseless cost assessment

S.rollouts(1:ro_par.reps) = S.rollouts;  % one data structure for each repetition

for i=1:n_dmps,                     % initialize DMPs
    dcp('clear',i);
    dcp('init',i,ro_par.n_dmp_bf,sprintf('pi2_dmp_%d',i),0);
    
    % use the in-built function to initialize the dcp with reference trajectory
    dcp('Batch_Fit',i,ro_par.duration,ro_par.Ts,S.ref.r(i,:)',S.ref.r_d(i,:)',S.ref.r_dd(i,:)');
    dcp('reset_state',i,ro_par.start(i));
    dcp('set_goal',i,ro_par.goal(i),1);
end

S.psi       = dcp('run_psi',1, ro_par.duration, ro_par.Ts); % Obtain basis functions
S_eval.psi  = S.psi;
dcp('reset_state',1,ro_par.start(1));
dcp('set_goal',1,ro_par.goal(1),1);

rm.activation = init_activation(S, rm);
rm.outcome_handles = init_outcome_handles(rm);

end