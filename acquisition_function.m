function [ af ] = acquisition_function( S, ro_par, rm, roll_out)

x = zeros(length(rm.D), rm.n_ff);
y = zeros(length(rm.D), 1);

for i = 1:length(rm.D)
    
    x(i,:)  = rm.D(i).sum_out(1,:);
    y(i)    = rm.D(i).R_expert;
    
end

[m, s2] = gp(rm.hyp, @infExact, rm.meanfunc, rm.covfunc, rm.likfunc,...
    x, y, roll_out.sum_out(1,:));

sigmaPoints = m + [1 -1].*sqrt(s2);
epd = zeros(2,1);

for s = 1:length(sigmaPoints)
    
    gamma_tilda = zeros(ro_par.reps,1);
    gamma_star = zeros(ro_par.reps,1);
    
    for k = 1:ro_par.reps
        
        [gamma_tilda(k), ~] = gp(rm.hyp, @infExact, rm.meanfunc, rm.covfunc, rm.likfunc,...
            [x ; roll_out.sum_out(1,:) ], [y; sigmaPoints(s)], S.rollouts(k).sum_out(1,:));
        
        [gamma_star(k), ~] = gp(rm.hyp, @infExact, rm.meanfunc, rm.covfunc, rm.likfunc,...
            x, y, S.rollouts(k).sum_out(1,:));
        
    end
    
    % Softmax
    gamma_tilda = exp(max(gamma_tilda)-gamma_tilda)/sum(exp(gamma_tilda));
    gamma_star  = exp(max(gamma_star)-gamma_star)/sum(exp(gamma_star));
    
    epd(s,1) = sum(gamma_star.*log(gamma_star./gamma_tilda));
    
end

af = mean(epd);