function [ W ] = get_time_weight(S, dmp_par)

% average updates over time
% the time weighting matrix (note that this done based on the true duration of the
% movement, while the movement "recording" is done beyond D.duration). Empirically, this
% weighting accelerates learning (don't know why though).
N = (S.n_end:-1:1)';

% the final weighting vector takes the kernel activation into account
W = (N*ones(1, dmp_par.n_dmp_bf)).*S.psi;

% ... and normalize through time
W = W./(ones(S.n_end, 1)*sum(W, 1));

end