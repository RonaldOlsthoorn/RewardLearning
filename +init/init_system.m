function [ system ] = init_system(system_par)
% 

    if strcmp(system_par.system, 'UR5')
       system = plant.SystemUR5(system_par); 
    end

end

