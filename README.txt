% Before running anything, make sure the gpml and robotics library are 
% loaded. If your initial matlab folder is the root of this project, you 
% should be fine. If you navigated to the project root, just run
%
% startup
%
% Two different kind of commands are available to run a SARL protocol:
% - run_learning('<protocol_name>'), to perform a single run of a protocol
% and save the results in +output.
% - run_multi_learning('<protocol_name>'), to perform 20 consecutive runs 
% a protocol to and save the results in +output.
%
% Protocols
% -viapoint_single. Viapoint tracking task using a single gp reward model.
% -viapoint_multi. Viapoint tracking task using a multi gp rewad model.
% -viapoint_advancedx_single. Viapoint/viaplane task using a single gp 
% reward model.
% -viapoint_advancedx_multi. Viapoint/viaplane task using a multi gp reward 
% model.
% -viapoint_advancedx_var_single. Viapoint/viaplane task using a single gp 
% reward model that includes end effector variance as feature.
% -viapoint_advancedx_var_multi. Viapoint/viaplane task using a multi gp 
% reward model that includes end effector variance as feature.
% 
% Add '_manual' to protocol name to rate yourself. Enjoy.
% 
% Ronald Olsthoorn (ronaldolsthoorn1@gmail.com)