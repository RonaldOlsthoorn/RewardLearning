function display_batch_result(res)
%

figure

for i = 1:length(res)
    
    subplot(1, 3, 1)
    hold on;
    plot(res(i).final_rollout.time, res(i).final_rollout.tool_positions(1,:), 'b');
    
    subplot(1, 3, 2)
    hold on;
    plot(res(i).final_rollout.time, res(i).final_rollout.tool_positions(2,:), 'b');
    
    subplot(1, 3, 3)
    hold on;
    plot(res(i).final_rollout.tool_positions(1,:), res(i).final_rollout.tool_positions(2,:), 'b');
end

% overlay
    
end

