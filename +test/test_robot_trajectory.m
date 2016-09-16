p = init.read_protocol('+protocols/protocol_robot.txt');

% roll out parameters
dmp_par.start        = p.start;
dmp_par.goal         = p.goal;
dmp_par.duration     = p.duration;
dmp_par.Ts           = p.Ts;
dmp_par.n_dmp_bf     = p.n_dmp_bf;
dmp_par.n_dmps       = p.n_dmps;

S.t             = 0:p.Ts:(p.duration-p.Ts); % time vector
S.n_end         = length(S.t);              % length of total simulation
S.ref = p.ref;

% initialize the reference, if used.
if ~strcmp('none', p.ref)
    ref_function    = str2func(strcat('refs.', p.ref));
    S.ref           = ref_function(dmp_par);
end

S = init.init_dmps( S, dmp_par );