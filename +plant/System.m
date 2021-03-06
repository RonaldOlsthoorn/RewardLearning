classdef System < handle
% Base class for open-loop systems.

    properties
        
        init_state;
    end
    
    methods(Abstract)
        
        output = run_increment(control_input)
        set_init_state(obj, is);
    end    
end

