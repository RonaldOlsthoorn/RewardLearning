function [ c ] = init_controller(controller_par)
% create and initialise controller.

switch controller_par.type
    case 'controllerPID'
        c = controller.ControllerPID(controller_par.Kp,...
        controller_par.Ki,...
        controller_par.Kd);
    case 'controllerInvKin'
        c = controller.ControllerPID();
    otherwise 
        c = [];
end
        
end

end

