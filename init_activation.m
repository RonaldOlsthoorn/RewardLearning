function [ rm ] = init_activation( S, rm )

seg = S.n_end/rm.n_segments;
i = (1:rm.n_segments) -1;
rm.seg_start = floor(seg*i);
rm.seg_start(1) = 1;
rm.seg_end = [rm.seg_start(2:end)+1 S.n_end];