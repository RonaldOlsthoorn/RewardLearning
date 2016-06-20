function [ S ] = compute_reward(S, ro_par, rm )
%Computes the reward of the batch of roll-outs in S.
outcomes = compute_outcomes(S, rm, ro_par);
sum_out = rot90(rot90(cumsum(rot90(rot90(outcomes)))));


%sum_out = reshape(sum(outcomes,1), [length(outcomes(1,:,1)),length(outcomes(1,1,:))]);

% iterate over each sample trajectory

x = zeros(length(rm.D), rm.n_ff);
y = zeros(length(rm.D), 1);


for i = 1:length(rm.D)
    
    x(i,:)  = rm.D(i).sum_out(1,:);
    y(i)    = rm.D(i).R_expert;
    
end

for k = 1:ro_par.reps,
    
    [m, s2] = gp(rm.hyp, @infExact, rm.meanfunc, rm.covfunc, rm.likfunc,... 
                    x, y, squeeze(sum_out(:,k,:)));
   
    S.rollouts(k).outcomes  = squeeze(outcomes(:,k,:));
    S.rollouts(k).sum_out   = squeeze(sum_out(:,k,:));
    S.rollouts(k).r         = m;
    S.rollouts(k).R         = m(1);
    
end


