clear all; close all; clc;

rm.meanfunc = {@meanSum, {@meanLinear, @meanConst}}; 
rm.covfunc = @covSEard; 
rm.hyp.cov = [1; 1]; 
rm.hyp.mean = [1; 1];
rm.likfunc = @likGauss; 
rm.hyp.lik = log(0.1);

x = [1000 ; 2000 ; 3000];
y = [1; 2; 3];
z = 0:10:4000;

[m, ~] = gp(rm.hyp, @infExact, rm.meanfunc, rm.covfunc, rm.likfunc,...
    x, y, z');

figure
hold on
plot(z,m);
plot(x,y,'x');

rm.hyp = minimize(rm.hyp, @gp, -100, @infExact, rm.meanfunc, rm.covfunc, rm.likfunc, x, y);

rm.hyp = minimize(rm.hyp, @gp, -100, @infExact, rm.meanfunc, rm.covfunc, rm.likfunc, x, y);

[m, ~] = gp(rm.hyp, @infExact, rm.meanfunc, rm.covfunc, rm.likfunc,...
    x, y, z');

figure
hold on
plot(z,m);
plot(x,y,'x');
