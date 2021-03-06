function [ summary ] = run_multi_learning(protocol_name)
% protocol_name: select from +protocols package

summary = output.Summary();

for i = 1:2

    disp(strcat('run number: ',{' '}, num2str(i)));
    m1 = MovementLearner(protocol_name);
    res = m1.run_movement_learning();
    summary.add_result(res);
    close all;
end

vname=@(x) inputname(1);
summary_struct = summary.to_struct();

try
    if isempty(strfind(protocol_name, 'manual'))
        save(strcat('+output/computer/', ...
            protocol_name, '_summary'), vname(summary_struct));
    else
        save(strcat('+output/manual/', ...
            protocol_name, '_summary'), vname(summary_struct));
    end
catch
    save(strcat(protocol_name, '_summary'), vname(summary_struct));
end