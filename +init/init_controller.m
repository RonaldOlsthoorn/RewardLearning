function [ c ] = init_controller(controller_par, system)
% Create and initialize controller.

switch controller_par.type
    case 'controllerPID'
        c = controller.ControllerPID(controller_par.Kp,...
        controller_par.Ki,...
        controller_par.Kd);
    case 'controllerInvKin'
        c = controller.ControllerInvKinPerfect(controller_par, system);
    case 'controllerImperfect'
        c = controller.ControllerImperfect();
    otherwise 
        c = [];
end
        
end