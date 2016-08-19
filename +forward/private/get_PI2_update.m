function theta = get_PI2_update(S, forward_par)
% returns the new policy, based on the new set of roll-outs.
% S is the data structure of all roll outs.
global n_dmps;
global dcps;

dtheta_per_sample = forward.get_PI2_update_per_sample(S, forward_par);

% normalize over samples
dtheta = dtheta_per_sample./ ...
    repmat(sum(dtheta_per_sample,2), ...
    [1, forward_par.reps, 1]);

% Add 
theta = zeros(n_dmps*forward_par.n_dmp_bf, forward_par.reps);

for i=1:n_dmps,    
    theta((((i-1)*forward_par.n_dmp_bf)+1):(i*forward_par.n_dmp_bf),:) = ...
        dcps(i).w*ones(1,forward_par.reps) + squeeze(dtheta(i,:,:))';

end