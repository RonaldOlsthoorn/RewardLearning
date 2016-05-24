function [ w ] = update_reward( S , rm)

find_nominee = true;

while find_nominee
    
    [max_outcome, set] = find_max_outcome(S, rm);
    
    if strcmp(set, 'S') && rm.af(max_outcome)/rm.rating_noise > rm.improve_tol
        
        d.R_expert = query_expert(max_outcome, rm.rating_noise);
        d.w = rm.weights;
        
        if exist('rm.D','var')
            rm.D = [rm.D d];
        else
            rm.D = d;
        end
        
    else
        find_nominee = false;
    end
    
end

