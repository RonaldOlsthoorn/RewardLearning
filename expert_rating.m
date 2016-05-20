function [ R_expert ] = expert_rating( outcome, noise )
% Outcome: column vector containing the outcomes (aka feature functions
% for reward function) of a trajectory
% noise: standard deviation of the expert rating uncertainty

w_true = [0.5; 0.5; 0.1; 0.1];

R_expert = w_true*outcome + noise*randn;

end

