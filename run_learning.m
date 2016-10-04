function run_learning(protocol_name)
% protocol_name: select from +protocols package

m1 = MovementLearner(protocol_name);

[W, R] = m1.run_movement_learning();

disp(W);
disp(R);