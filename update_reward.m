function [ rm ] = update_reward(  S, rm, ro_par)

find_nominee = true;

while find_nominee
    
    [max_outcome, set, epd] = find_max_outcome(S, rm, ro_par);
    
    if strcmp(set, 'S') && rm.af(S, ro_par, rm, max_outcome)/rm.rating_noise > rm.improve_tol
        
        D.R_expert = query_expert(max_outcome.sum_out(1,:), rm.rating_noise);
        D.outcomes = max_outcome.outcomes;
        D.sum_out = max_outcome.sum_out;
        
        rm.D = [rm.D D];
        
    else
        find_nominee = false;
    end
    
end

x = zeros(length(rm.D), rm.n_ff);
y = zeros(length(rm.D), 1);


for i = 1:length(rm.D)
    
    x(i,:)  = rm.D(i).sum_out(1,:);
    y(i)    = rm.D(i).R_expert;
    
end

rm.hyp = minimize(rm.hyp, @gp, -100, @infExact, rm.meanfunc, rm.covfunc, rm.likfunc, x, y);

