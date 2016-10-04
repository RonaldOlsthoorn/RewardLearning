function [ c ] = init_controller(controller_par)
% create and initialise controller.

if strcmp('controllerPID', controller_par.type)
    c = controller.ControllerPID(controller_par.Kp,...
        controller_par.Ki,...
        controller_par.Kd);
end

end

