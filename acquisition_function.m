function [ af ] = acquisition_function( S, ro_par, rm, roll_out)

[m, s2] = gp(rm.seg(1).hyp, @infExact, ...
            rm.meanfunc, rm.covfunc, rm.likfunc,...
            rm.seg(1).sum_out, rm.seg(1).R_expert,...
            roll_out.sum_out(1,:));

sigmaPoints = m + [1 -1].*sqrt(s2);
epd = zeros(2,1); 

for s = 1:length(sigmaPoints)
    
    gamma_tilda = zeros(ro_par.reps,1);
    gamma_star  = zeros(ro_par.reps,1);
    
    for k = 1:ro_par.reps
        
        [gamma_star(k), ~] = gp(rm.seg(1).hyp, @infExact, rm.meanfunc, rm.covfunc, rm.likfunc,...
            [rm.seg(1).sum_out; roll_out.sum_out(1,:)], [rm.seg(1).R_expert; sigmaPoints(s)],...
            S.rollouts(k).sum_out(1,:));
        
        [gamma_tilda(k), ~] = gp(rm.seg(1).hyp, @infExact, rm.meanfunc, rm.covfunc, rm.likfunc,...
            [rm.seg(1).sum_out], [rm.seg(1).R_expert],...
            S.rollouts(k).sum_out(1,:));
        
    end
    
    minGamma = min(gamma_tilda);
    maxGamma = max(gamma_tilda);
    
    gamma_tilda = exp(-(gamma_tilda - minGamma*ones(ro_par.reps, 1))./...
    ((maxGamma-minGamma)*ones(ro_par.reps, 1)));

    gamma_tilda = gamma_tilda./sum(gamma_tilda);
    
    minGamma = min(gamma_star);
    maxGamma = max(gamma_star);

    gamma_star = exp(-(gamma_star - minGamma*ones(ro_par.reps, 1))./...
    ((maxGamma-minGamma)*ones(ro_par.reps, 1)));

    gamma_star = gamma_star./sum(gamma_star);
    
    epd(s,1) = sum(gamma_star.*log(gamma_star./gamma_tilda));
    
end

af = mean(epd);