function [ reference ] = init_reference( reference_par )
% initialise the reference trajectory. If needed use inverse kinematics
% block.
% reference_par: struct containing start and goal and trajectory function. 


if strcmp(reference_par.trajectory, 'trajectory_robot')
    reference = refs.Reference(reference_par);
    [t, t_d] = refs.trajectory_robot(reference_par);
    reference.r_tool = t;
    reference.r_tool_d = t_d;
else
    reference = [];
end

if reference_par.use_ik
    
    [j, j_d] = ik.map_ref(reference.r_tool, reference_par, ik.create_model_UR5());
    reference.r_joints = j;
    reference.r_joints_d = j_d;
end

end

