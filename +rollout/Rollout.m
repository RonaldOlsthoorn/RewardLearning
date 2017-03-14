classdef Rollout 
    % Container class used as a fancy struct.
    
    properties
        iteration;
        index;
        
        policy;
        control_input;
        joint_positions;
        joint_speeds;
        tool_positions;
        tool_speeds;
        time;
   
        outcomes;
        sum_out;
        
        xd;
        
        r;
        r_cum;
        R;
        R_expert;
        R_true;
        
        R_var;
        
        R_segments;
        
        v_feed;
    end
    
    methods
        
        function res = equals(obj, in_ro)
                 
            if in_ro.iteration==obj.iteration...
                    && in_ro.index == obj.index
                res=true;
            else
                res=false;
            end
        end
        
        
        % Make a copy of a handle object.
        function struct = to_struct(obj)
            % Instantiate new object of the same class.
            
            % Copy all non-hidden properties.
            p = properties(obj);
            for i = 1:length(p)
                
                if ~isempty(p{i})
                    struct.(p{i}) = obj.(p{i});
                end
            end
        end
                
    end 
       
    methods(Static)
        
        function obj = from_struct(struct)
            
            obj = rollout.Rollout;
            
            f = fields(struct);
            
            for i = 1:length(f)
                
                obj.(f{i}) = struct.(f{i});
            end
        end
    end
end