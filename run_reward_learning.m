function run_reward_learning(protocol_name)
% This is a simple implementation of Active reward learning on a 1 DOF Discrete
% Movement Primitive. It serves as illustration how PI2 learning works.
% To allow easy changes, key parameters have been kept modular. The
% experimental protocal is read from a protocal text file, <protocol_name>,
% which should be self-explantory.
%
% This work is based on the paper:
% Daniel C, Kroemer O, Viering M., Metz J, Peters J (2015)
% Active reward learning with a novel acquisition function.
% Autonomous Robot.
%
% The simulation control a 1 DOF pendulum with the DMP. This could be easily
% changed to be a more complex nonlinear system.
% Ronald Olsthoorn, May 2016

clc

tic

% read the protocol file
p = read_protocol(protocol_name);

% initializes a 1 DOF DMP -- this is dones as two independent DMPs as the
% Matlab DMPs currently do not support multi-DOF DMPs.
global n_dmps;
n_dmps = 1;

[ S, S_eval, ro_par, ro_par_eval, ...
    sim_par, rm ] = init(p);

R_total = zeros(1,2); % used to store the learning trace
DMP_Weights = zeros(ro_par.n_dmp_bf,1); % used to store weight trace

% before we run the main loop, we need 1 demo to initialize the reward
% model
rm = run_first_demo(S, rm, ro_par, sim_par);

i=1;

while converged(rm, i)~=1,
    
    % run learning roll-outs with a noise annealing multiplier
    ro_par.noise_mult =  double(100 - i+1)/double(100);
    ro_par.noise_mult = max([0.1 ro_par.noise_mult]);
    
    % first batch, collect full nr of roll-outs
    if(i==1)
        S = run_rollouts(S, ro_par, sim_par, i, ro_par.reps);
    else
        % after that mix new roll-outs with reused rollouts
        S = run_rollouts(S, ro_par, sim_par, i, ro_par.reps - ro_par.n_reuse);
    end
    
    S = compute_reward(S, ro_par, rm);        
    rm = update_database(S, ro_par, rm, ro_par.reps);
    
%    [ S_eval, W ] = evaluate_progress( S, S_eval, ro_par_eval, ...
%                                            ro_par, sim_par, rm, i );
                                
%     R_total = [R_total, sum(S_eval.rollouts(1).R)];
%     DMP_Weights = [DMP_Weights, W'];
            
    % update reward model
    update_reward(S, rm, ro_par);
    
    % perform the PI2 update
    update_PI2(S, ro_par);
    
    if (i > 1 && ro_par.n_reuse > 0)
        S = importance_sampling(S, ro_par, ro_par.n_reuse);
    end
    
    i=i+1;
end

toc

% perform the final noiseless evaluation to get the final cost
S_eval=run_rollouts(S_eval, ro_par, sim_par, 1);

% % compute all costs in batch from, as this is faster in matlab
% eval(sprintf('R_eval=%s(S_eval);',S_eval.rollouts(1).));
% fprintf('%5d.Cost = %f \n',i,sum(R_eval));
% 
% printResult(S, S_eval, R, R_eval, R_total, DMP_Weights);