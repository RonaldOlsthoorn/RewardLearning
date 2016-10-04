function [ c ] = init_controller(controller_par)

    c = controller.ControllerPID(controller_par.Kp,...
                                          controller_par.Ki,...
                                          controller_par.Kd);

end

