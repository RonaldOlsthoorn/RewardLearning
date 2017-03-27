function [res] = run_learning(protocol_name)
% protocol_name: select from +protocols package

m1 = MovementLearner(protocol_name);
res = m1.run_movement_learning();

vname=@(x) inputname(1);

res_struct = res.to_struct();

try
    if isempty(strfind(protocol_name, 'manual'))
        save(strcat('+output/computer', ...
            protocol_name), vname(res_struct));
    else
        save(strcat('+output/computer', ...
            protocol_name), vname(res_struct));
    end
catch
    save(strcat(protocol_name), vname(res_struct));
end
