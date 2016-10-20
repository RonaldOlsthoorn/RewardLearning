function [reference] = init_reference(reference_par)
% initialise the reference trajectory. If needed use inverse kinematics
% block.
% reference_par: struct containing start and goal and trajectory function.

switch reference_par.trajectory
    case 'trajectory_robot'
        reference = refs.Reference(reference_par);
        [t, t_d] = refs.trajectory_robot(reference_par);
        reference.r_tool = t;
        reference.r_tool_d = t_d;
        
        if reference_par.use_ik
            
            [j, j_d] = ik.map_ref(reference.r_tool, reference_par, ik.create_model_UR5());
            reference.r_joints = j;
            reference.r_joints_d = j_d;
        end
        
    case '2dof'
        reference = refs.Reference(reference_par);
        [t, t_d] = refs.ref_2dof(reference_par);
        reference.r_tool = t;
        reference.r_tool_d = t_d;
        
        if reference_par.use_ik
            
            [j, j_d] = ik.map_ref2(reference.r_tool, reference_par, ik.create_model_2DOF());
            reference.r_joints = j;
            reference.r_joints_d = j_d;
        end
        
    otherwise
        reference = [];
end



end

