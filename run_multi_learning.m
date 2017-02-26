function [ res ] = run_multi_learning(protocol_name)
% protocol_name: select from +protocols package

l = 4;

for i = 1:l

    m1 = MovementLearner(protocol_name);
    m1.run_movement_learning();
    end_result(i) = m1.export();
    
    close all;
end

res = end_result;

end
