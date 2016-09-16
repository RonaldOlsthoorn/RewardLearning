clear; close all; clc;

p = init.read_protocol('+protocols/protocol_robot.txt');

% roll out parameters
dmp_par.start        = p.start_tool;
dmp_par.goal         = p.goal_tool;
dmp_par.start_joint  = p.start_joint;
dmp_par.goal_joint   = p.goal_joint;
dmp_par.start_tool   = p.start_tool;
dmp_par.goal_tool    = p.goal_tool;
dmp_par.Ts           = p.Ts;
dmp_par.duration     = p.duration;

S.t             = 0:p.Ts:(p.duration-p.Ts); % time vector
S.n_end         = length(S.t);              % length of total simulation
S.ref = p.ref;

% initialize the reference, if used.
if ~strcmp('none', p.ref)
    ref_function    = str2func(strcat('refs.', p.ref));
    S.ref           = ref_function(dmp_par);
end

if p.use_ik
    S = init.init_dmps_ik(S, dmp_par );
else
    S = init.init_dmps(S, dmp_par );
end