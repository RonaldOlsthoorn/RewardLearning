function [ af ] = acquisition_epd( S_original, ro_par, rm, roll_out)
% implements an Expected Policy Divergence acquisition function.
% S_original: struct containing all samples considered in the current
% iteration.
% ro_par: struct containing roll-out parameters
% rm: struct containing the reward model
% roll_out: struct containing the specific roll-out for which the acquistion
% value needs to be computed

import forward.*

epd = zeros(rm.n_segments, 2);

for segment = 1:rm.n_segments
    
    [m, s2] = gp(rm.seg(segment).hyp, @infExact, ...
        rm.meanfunc, rm.covfunc, rm.likfunc,...
        rm.seg(segment).sum_out, rm.seg(segment).R_expert,...
        roll_out.seg(segment).sum_out);
    
    sigmaPoints = m + [1 -1].*sqrt(s2);

    
    for sigma = 1:length(sigmaPoints)
        
        theta_tilda = get_PI2_update(S_original, ro_par);
        
        rm_fake = rm;
        rm_fake.seg(segment).sum_out = [rm_fake.seg(segment).sum_out; roll_out.seg(segment).sum_out];
        rm_fake.seg(segment).R_expert = [rm_fake.seg(segment).R_expert; sigmaPoints(sigma)];
        
        S_fake = compute_reward(S_original, ro_par, rm_fake);
        
        theta_star = get_PI2_update(S_fake, ro_par);
             
        theta_star_mean = mean(theta_star, 2);
        theta_star_cov  = diag(var(theta_star'));
        
        theta_tilda_mean = mean(theta_tilda,2);
        theta_tilda_cov = diag(var(theta_tilda'));
        
        theta_star_p = mvnpdf(theta_star', theta_star_mean', theta_star_cov);
        theta_tilda_p = mvnpdf(theta_tilda', theta_tilda_mean', theta_tilda_cov);
        
        epd(segment, sigma) = sum(theta_star_p.*log(theta_star_p./theta_tilda_p));
        
    end
    
end

af = mean(mean(epd));