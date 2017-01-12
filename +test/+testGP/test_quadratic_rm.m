clear; close all; clc;

grid_x = 0:0.05:0.6;
grid_y = 0:0.05:0.6;

m1 = MovementLearner('viapoint_multi');

batch_rollouts = db.RolloutBatch();

for i = 1:length(grid_x)
    for j = 1:length(grid_y)
        
        r = rollout.Rollout();
        r.outcomes = [0, 0; grid_x(i), grid_y(j); 0, 0; 0, 0];
        r.tool_positions(:, 300) = [grid_x(i); grid_y(j)];
        r.R_expert = m1.environment.expert.query_expert(r);
        batch_rollouts.append_rollout(r);
    end
end

m1.reward_model.add_batch_demonstrations(batch_rollouts);
m1.reward_model.print();