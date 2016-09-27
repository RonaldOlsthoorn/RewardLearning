function run_learning(protocol_name)

m1 = MovementLearner(protocol_name);

[W, R] = m1.run_movement_learner();