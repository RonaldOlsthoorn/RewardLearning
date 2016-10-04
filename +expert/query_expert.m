function [ R_expert ] = query_expert( sum_out, segment, noise )
% Outcome: column vector containing the outcomes (aka feature functions
% for reward function) of a trajectory
% noise: standard deviation of the expert rating uncertainty
% 
% w_true = [0.1 1 2 4
%           0.1 1 2 4];
      

% w_true = [0.1 1 2 4
%           0.1 1 2 4];
      
w_true = [1 1 1 1
          1 1 1 1];
      
R_expert = w_true(:,segment)'*sum_out' + noise*randn(1,1);

end