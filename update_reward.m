function [ rm ] = update_reward(  S, rm, ro_par)

find_nominee = true;

while find_nominee
    
    [max_outcome, set, epd] = find_max_outcome(S, rm, ro_par);
    
    if strcmp(set, 'S') && epd/rm.rating_noise > rm.improve_tol
        
        for s=1:rm.n_segments
            
           rm.seg(s).sum_out =  [rm.seg(s).sum_out; max_outcome.seg(s).sum_out];
           rm.seg(s).R_expert = [rm.seg(s).R_expert;...
                                 query_expert(max_outcome.seg(s).sum_out, rm.rating_noise)];
           
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
