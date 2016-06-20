clear all; close all; clc;

rm.meanfunc = {@meanSum, {@meanLinear, @meanConst}}; 
rm.covfunc = @covSEard; 
rm.hyp.cov = [1; 1]; 
rm.hyp.mean = [1; 1; 1];
rm.likfunc = @likGauss; 
rm.hyp.lik = log(0.1);

x = [1 1 ; 2 2 ; 3 3];
y = [1; 2; 2.5];
z = -10:0.1:10;

[m, ~] = gp(rm.hyp, @infExact, rm.meanfunc, rm.covfunc, rm.likfunc,...
    x, y, z');

rm.hyp = minimize(rm.hyp, @gp, -100, @infExact, rm.meanfunc, rm.covfunc, rm.likfunc, x, y);

[m, ~] = gp(rm.hyp, @infExact, rm.meanfunc, rm.covfunc, rm.likfunc,...
    x, y, z');
