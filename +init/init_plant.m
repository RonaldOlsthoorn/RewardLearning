function [p] = init_plant(plant_par, controller_par)
% create and initialise plant
% plant_par: struct containing type of plant
% controller: controller used to control the plant's system

switch plant_par.type
    case 'UR5'
        c = init.init_controller(controller_par);
        p = plant.PlantUR5(plant_par, c);
    case '2-dof'
        s = plant.System2DOF(plant_par);
        c = init.init_controller(controller_par, s);
        p = plant.Plant2DOF(s, c);
    otherwise
        p = [];
end

end

