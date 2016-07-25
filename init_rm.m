function [ rm ] = init_rm( S, rm )
% setup the reward model by dividing the rollout time in pieces. Each piece
% will have its own gp.

rm.seg_start = zeros(1, rm.n_segments);
rm.seg_end   = zeros(1, rm.n_segments);

seg = S.n_end/rm.n_segments;
rm.seg_end(end) = S.n_end;
rm.seg_start(1) = 1;

if rm.n_segments > 1
    i=1:(rm.n_segments-1);
    rm.seg_end(1:end-1) = floor(i*seg);
    rm.seg_start(2:end) = rm.seg_end(1:end-1)+1;
end
