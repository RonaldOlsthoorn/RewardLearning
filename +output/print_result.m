function  print_result(S, S_eval, R, R_eval, R_total)
% Present the result of the complete PI2 algorithm.
% D: struct containing the last set of roll-outs
% D_eval: struct containing the noise-less evaluation of the 
% final solution.
% R: reward of the last batch of roll-outs
% R_eval: noise-less reward
% R_total: total noise-less reward per update

printProgress(S, S_eval,R, R_eval,D.updates+2); % print trajectory outputs

global par;

t = D.t;

% the reward for the last trajectory
figure;
subplot(1,2,1);
plot(t,R_eval);
xlabel('time [s]');
ylabel('Cost');
title('Cost curve');

subplot(1,2,2);
% plot learning curve
semilogy(R_total(:,1), R_total(:,2));
xlabel('Number of roll outs');
ylabel('Total cost of trajectory');
title('Learning curve');

drawnow;

body_animate(S_eval.t, S_eval.rollouts(1).q', par);