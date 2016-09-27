function [plant_par] = system_real_robot( input_args )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

    plant_par.controller = 'lousy_controller';
    plant_par.system = 'UR5';
    plant_par.sim = false;
    plant_par.dof = 6;
end

