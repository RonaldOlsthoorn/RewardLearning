function [res] = run_learning(protocol_name)
% protocol_name: select from +protocols package

m1 = MovementLearner(protocol_name);
res = m1.run_movement_learning();

vname=@(x) inputname(1);

res_struct = res.to_struct();

try
    save(strcat('+output/', protocol_name), vname(res_struct));
catch
    save(obj.protocol_s, 'to_save');
end