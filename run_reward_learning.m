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

[ S, S_eval, dmp_par, forward_par, forward_par_eval, ...
    sim_par, rm ] = init(p);

% before we run the main loop, we need 1 demo to initialize the reward
% model
rm = run_first_demo(S, rm, forward_par, dmp_par, sim_par);

i = 1;

while converged(rm, i)~=1,
    
    % first batch, collect full nr of roll-outs
    if(i==1)
        S = run_rollouts(S, dmp_par, forward_par, sim_par, i, forward_par.reps);
    else
        % after that mix new roll-outs with reused rollouts
        S = run_rollouts(S, dmp_par, forward_par, sim_par, i, forward_par.reps - forward_par.n_reuse);
    end
    
    S = compute_reward(S, forward_par, rm);
    rm = update_database(S, forward_par, rm, forward_par.reps);
    
    [ S_eval, ~ ] = evaluate_progress( S, S_eval, dmp_par, ...
        forward_par_eval, sim_par, rm, i );
    
    % update reward model
    update_reward(S, rm, forward_par);
    
    % perform the PI2 update
    forward_par = forward_par.forward_method(S, forward_par);
    
    if (i > 1 && forward_par.n_reuse > 0)
        S = importance_sampling(S, forward_par, forward_par.n_reuse);
    end
    
    i=i+1;
end

toc

% perform the final noiseless evaluation to get the final cost
S_eval = run_rollouts(S, dmp_par, forward_par, sim_par, i, forward_par.reps);

[ ~, ~ ] = evaluate_progress( S, S_eval, dmp_par, ...
    forward_par_eval, sim_par, rm, i );
