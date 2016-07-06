clear; close all; clc

protocol_name = 'test_protocol.txt';

p = read_protocol(protocol_name);

global n_dmps;
n_dmps = 1;

[ S, S_eval, ro_par, ro_par_eval, ...
    sim_par, rm ] = init(p);

R_total = zeros(1,2); % used to store the learning trace
DMP_Weights = zeros(ro_par.n_dmp_bf,1); % used to store weight trace

% before we run the main loop, we need 1 demo to initialize the reward
% model

S = run_rollouts(S, ro_par, sim_par, ro_par.reps);

outcomes =  compute_outcomes(S, ro_par, rm );
sum_out  = rot90(rot90(cumsum(rot90(rot90(outcomes)))));

zero_sum_out = zeros(ro_par.reps,rm.n_ff);
seg.sum_out = zero_sum_out;
seg.R_expert = zeros(ro_par.reps,1);

rm.seg(1:rm.n_segments) = seg;

for k = 1:ro_par.reps
    
    for s = 1:rm.n_segments
        
        rm.seg(s).sum_out(k,:)  = squeeze(sum_out(rm.seg_start(s),k,:));
        rm.seg(s).R_expert(k) = query_expert( rm.seg(s).sum_out(k,:) , rm.rating_noise );
    end
    
end

for s = 1:rm.n_segments
    
    rm.seg(s).hyp.cov = [10; 10; 14];
    rm.seg(s).hyp.mean = [];
    rm.seg(s).hyp.lik = log(0.1);
    
    rm.seg(s).hyp = minimize(rm.seg(s).hyp, @gp, -100, @infExact, ...
        [], rm.covfunc, rm.likfunc, ...
        rm.seg(s).sum_out, rm.seg(s).R_expert);
    
end


[m_x, m_y] = meshgrid(-300:5:-50, -300:5:-50);
z = zeros(length(m_x(:,1)),length(m_x(1,:)));
z_true = z;


for i = 1:length(m_x(:,1))
    for j = 1:length(m_y(:,1))
        
        [m, ~] = gp(rm.seg(1).hyp, @infExact, ...
            [], rm.covfunc, rm.likfunc,...
            rm.seg(1).sum_out(1,:), rm.seg(1).R_expert(1),...
            [m_x(i,j) m_y(i,j)]);
        
        z(i,j) = m;
        z_true(i,j) = query_expert([m_x(i,j) m_y(i,j)] , 0);
    end
end

fig = figure(1);
set (fig, 'Units', 'normalized', 'Position', [0,0,1,1]);


hold on
xlabel('x');
ylabel('y');
zlabel('z');

mesh(m_x, m_y, z);
%mesh(m_x, m_y, z_true);


scatter3(rm.seg(1).sum_out(1,1), rm.seg(1).sum_out(1,2), rm.seg(1).R_expert(1),'x', 'r');

