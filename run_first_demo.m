function rm = run_first_demo(S, rm, ro_par, sim_par)
% runs first roll-outs en queries the expert for its rating
% this is necessary for the initialization of the reward model.

% S: struct containing an empty set of roll-outs.
% rm: struct containing the reward model.
% ro_par: struct containing the rollout parameters.
% sim_par: struct containing the simulation parameters.

S = run_rollouts(S, ro_par, sim_par, 0, ro_par.reps);
outcomes =  compute_outcomes(S, ro_par, rm );

for s = 1:rm.n_segments
    sum_out(rm.seg_start(s):rm.seg_end(s),:,:) = ...
        rot90(rot90(cumsum(rot90(rot90(outcomes(rm.seg_start(s):rm.seg_end(s),:,:))))));
end

zero_sum_out = zeros(ro_par.reps, rm.n_ff);
seg.sum_out = zero_sum_out;
seg.R_expert = zeros(ro_par.reps,1);

rm.seg(1:rm.n_segments) = seg;

for k = 1:ro_par.reps
    
    for s = 1:rm.n_segments
        
        rm.seg(s).sum_out(k,:)  = squeeze(sum_out(rm.seg_start(s),k,:));
        rm.seg(s).R_expert(k) = query_expert( rm.seg(s).sum_out(k,:) , s, rm.rating_noise );
        
    end
end

for s = 1:rm.n_segments
    
    rm.seg(s).hyp.cov = [5; 5; 0];
    %rm.seg(s).hyp.mean = [ones(rm.n_ff,1); 1];
    rm.seg(s).hyp.mean = [];
    rm.seg(s).hyp.lik = log(0.1);
    
    rm.seg(s).hyp = minimize(rm.seg(s).hyp, @gp, -100, @infExact, ...
        rm.meanfunc, rm.covfunc, rm.likfunc, ...
        rm.seg(s).sum_out, rm.seg(s).R_expert);
    
end
clc

fig = figure(1);
set (fig, 'Units', 'normalized', 'Position', [0,0,1,1]);

for s = 1:rm.n_segments
    
    [m_x, m_y] = meshgrid(-150:5:50, -150:5:50);
    z = zeros(length(m_x(:,1)),length(m_x(1,:)));
    z_true = z;
       
    for i = 1:length(m_x(:,1))
        for j = 1:length(m_y(:,1))
            
            [m, ~] = gp(rm.seg(s).hyp, @infExact, ...
                [], rm.covfunc, rm.likfunc,...
                rm.seg(s).sum_out, rm.seg(s).R_expert,...
                [m_x(i,j) m_y(i,j)]);
            
            z(i,j) = m;
            z_true(i,j) = query_expert([m_x(i,j) m_y(i,j)] , s, 0);
        end
    end
    
    subplot(2,2,s);
    hold on
    xlabel('x');
    ylabel('y');
    zlabel('z');
    
    mesh(m_x, m_y, z);   
    scatter3(rm.seg(s).sum_out(:,1), rm.seg(s).sum_out(:,2), rm.seg(s).R_expert(:),'x', 'r');
end
