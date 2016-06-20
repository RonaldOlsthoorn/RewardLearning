function [ activation ] = init_activation( S, rm )

%pre compute activation functions
c_t = (0:S.t(end)/(rm.n_reward_bf-1):S.t(end));

psi_t = zeros(S.n_end, rm.n_reward_bf);
activation = zeros(length(S.t), length(c_t));


for j = 1:length(c_t)
    
    psi_t(:,j) = exp(-2*(c_t(j)*ones(1,length(S.t))-S.t).^2)';
    
end

for j = 1:length(c_t)
    
    activation(:,j) = psi_t(:,j)./(sum(psi_t,2));
    
end

