function [ rm ] = update_reward(  S, rm, ro_par)
% update the reward model whith the new drawn samples.
% S: struct containing the new drawn samples.
% rm: struct containing the reward model.
% ro_par: struct containing the roll_out parameters.

import expert.query_expert
import rollout.remove_rollout
import acquisition.find_max_outcome

find_nominee = true;
S_original = S;

while find_nominee
    
    [max_outcome, set, epd] = find_max_outcome(S_original, S, rm, ro_par);
    
    if (strcmp(set, 'S') && epd/rm.rating_noise > rm.improve_tol) 
        
        for s=1:rm.n_segments
            
           rm.seg(s).sum_out =  [rm.seg(s).sum_out; max_outcome.seg(s).sum_out];
           rm.seg(s).R_expert = [rm.seg(s).R_expert;...
                                 query_expert(max_outcome.seg(s).sum_out, s, rm.rating_noise)];
           
        end
        
        S = remove_rollout(S, max_outcome.index);
        
        if isempty(S.rollouts)
            find_nominee = false;
        end
                
    else
        find_nominee = false;
    end
end

for s = 1:rm.n_segments
      
    rm.seg(s).hyp = minimize(rm.seg(s).hyp, @gp, -100, @infExact, ...
        rm.meanfunc, rm.covfunc, rm.likfunc, ...
        rm.seg(s).sum_out, rm.seg(s).R_expert);
    
end
clc