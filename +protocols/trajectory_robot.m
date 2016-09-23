function [trajectory_par] = trajectory_robot()

    trajectory_par.start_tool= [-0.2619;-0.1091;0.3623;1.2088;-1.2107;-1.2104];
    trajectory_par.goal_tool= [-0.4619;-0.0091;0.3623;1.2088;-1.2109;-1.2103];
    trajectory_par.start_joint = [0;-2*pi/3;2*pi/3;0;pi/2;0];
    trajectory_par.goal_joint = [-0.2672;-1.6281;1.7727;-0.1439;1.3053;0];
    trajectory_par.use_ik = true;
    trajectory_par.duration = 8;
    trajectory_par.Ts = 0.01;
    trajectory_par.ref = 'ref_robot';    
end

