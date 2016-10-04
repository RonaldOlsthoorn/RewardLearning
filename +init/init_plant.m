function [ p ] = init_plant(plant_par, controller)
% create and initialise plant
% plant_par: struct containing type of plant
% controller: controller used to control the plant's system

    if strcmp(plant_par.type, 'UR5')
       p = plant.PlantUR5(plant_par, controller);
    end

end

