function [controller_par] = lousy_PID()

    controller_par.controller = 'lousy_controller';
    controller_par.Kp = 3;
    controller_par.Ki = 0;
    controller_par.Kd = 0.0375;
end

