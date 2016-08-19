function [max_outcome, set,  max_epd] = find_max_outcome(S_original, S, rm, ro_par)
% Computes the rollout which results in the greatest acquisition value in
% either S, the set of samples of the current iteration, or set D, the set
% containing all expert-queried samples thusfar.
% S_original: original set S containing all samples created in the current
% iteration.
% S: set containing all samples of S_original which are not queried by the
% expert.
% rm: struct containing all the reward model parameters as well as set D
% ro_par: struct containing roll-out parameters


for s = 1:rm.n_segments
    
    roll_out.seg(s).sum_out = S.rollouts(1).sum_out(rm.seg_start(s), :);
    roll_out.iteration = S.rollouts(1).iteration;
    roll_out.index = S.rollouts(1).index;
    
end

max_outcome = roll_out;
max_epd = rm.af(S_original, ro_par, rm, max_outcome);
set = 'S';

if (length(S.rollouts)>1)
    for i = 2:length(S.rollouts)
        
        for s = 1:rm.n_segments
            
            roll_out.seg(s).sum_out = S.rollouts(i).sum_out(rm.seg_start(s), :);
        end
        
        roll_out.iteration = S.rollouts(i).iteration;
        roll_out.index = S.rollouts(i).index;
        
        epd = rm.af(S_original, ro_par, rm, roll_out);
        
        if  epd > max_epd
            max_outcome = roll_out;
            max_epd = epd;
        end
    end
end

for i = 1:length(rm.seg(1).R_expert)
    
    for s = 1:rm.n_segments
        
        roll_out.seg(s).sum_out = rm.seg(s).sum_out(i,:);
        
    end
    
    epd = rm.af(S_original, ro_par, rm, roll_out);
    
    if epd >= max_epd
        max_outcome = roll_out;
        set = 'D';
    end
end

end