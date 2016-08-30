function [ S ] = compute_reward(S, ro_par, rm )
% Computes the reward of a batch of roll-outs.
% S: struct containing all the roll-outs of this iteration.
% ro_par: struct containing all the roll-out parameters.
% rm: struct containing the reward model.

outcomes = reward.compute_outcomes(S, ro_par, rm);

for s = 1:rm.n_segments
    sum_out(rm.seg_start(s):rm.seg_end(s),:,:) = ...
        rot90(rot90(cumsum(rot90(rot90(outcomes(rm.seg_start(s):rm.seg_end(s),:,:))))));
end

% sum_out = reshape(sum(outcomes,1), [length(outcomes(1,:,1)),length(outcomes(1,1,:))]);
% iterate over each sample trajectory

for k = 1:ro_par.reps,
    
    S.rollouts(k).outcomes  = squeeze(outcomes(:,k,:));
    S.rollouts(k).sum_out   = squeeze(sum_out(:,k,:));
    S.rollouts(k).r = zeros(S.n_end,1);
    
    for s = rm.n_segments:-1:1
        
        [m, ~] = gp(rm.seg(s).hyp, @infExact, ...
            rm.meanfunc, rm.covfunc, rm.likfunc,...
            rm.seg(s).sum_out, rm.seg(s).R_expert,...
            squeeze(sum_out(rm.seg_start(s):rm.seg_end(s),k,:)));
               
        if s<rm.n_segments
            S.rollouts(k).r(rm.seg_start(s):rm.seg_end(s)) = m + S.rollouts(k).r(rm.seg_start(s+1));
        else
            S.rollouts(k).r(rm.seg_start(s):rm.seg_end(s)) = m;
        end
        
        S.rollouts(k).R(s) = m(1);
        
    end
    
end


