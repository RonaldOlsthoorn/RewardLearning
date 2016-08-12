function test_importance_sampling()
clear; clc; close all;

disp('first n =10');
disp(bruteForceSampling(10));
disp('first n =100');
disp(bruteForceSampling(100));
disp('first n =1000');
disp(bruteForceSampling(1000));
disp('first n =10000');
disp(bruteForceSampling(10000));
disp('first n =100000');
disp(bruteForceSampling(100000));
disp('first n =1000000');
disp(bruteForceSampling(1000000));

disp('first n =10');
disp(importanceSampling(10));
disp('first n =100');
disp(importanceSampling(100));
disp('first n =1000');
disp(importanceSampling(1000));
disp('first n =10000');
disp(importanceSampling(10000));
disp('first n =100000');
disp(importanceSampling(100000));
disp('first n =1000000');
disp(importanceSampling(1000000));

end

function [mu_est] = bruteForceSampling(n)

x = randn([1, n]);
inInterval = isInInterval(x);

mu_est = sum(x.*inInterval)/sum(inInterval);

end

function [mu_est] = importanceSampling(n)

    x = rand(1,n);
    w = f(x);
    mu_est = (1/n)*(x*w');
end

function [res] = f(x)

    p = normcdf([0 1]);
    norm_interval = p(2) - p(1);
    
    res = normpdf(x, 0, 1)/norm_interval;
    
end

function [inInterval] = isInInterval(x)

    inInterval = (x <=1 & x>=0);
end
