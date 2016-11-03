function [ c ] = init_controller(controller_par, system)
% create and initialise controller.

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