function [ p ] = init_plant(plant_par, controller)

    if strcmp(plant_par.type, 'UR5')
       p = plant.PlantUR5(plant_par, controller);
    end

end

