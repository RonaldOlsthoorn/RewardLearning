classdef MultiGPRewardModel < reward.RewardModel
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        gps;
    end
    
    methods
        
        function rollout = add_reward(obj, rollout)
            
            for i = 1:length(obj.gps)
                
                R(i) = obj.gps(i).interpolate(rollout.sum_out(i));
            end
            
            rollout.R = sum(R);
        end
        
        function add_demonstration(obj, demonstration)
            
           obj.gps(i).add_point 
        end
        
        
        % Make a copy of a handle object.
        function new = copy(this)
            % Instantiate new object of the same class.
            new = reward.MultiGPRewardModel();
            
            % Copy all non-hidden properties.
            p = properties(this);
            for i = 1:length(p)
                if strcmp(p{i}, 'gp')
                    new.(p{i}) = this.(p{i}).copy();
                else
                    new.(p{i}) = this.(p{i});
                end
            end
        end
    end
    
end

