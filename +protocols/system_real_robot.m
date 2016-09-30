function [system_par] = system_real_robot()

    system_par.system = 'UR5';
    system_par.sim = false;
    system_par.dof = 6;
    system_par.Ts = 0.01;
end

