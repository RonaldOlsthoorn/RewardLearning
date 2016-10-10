classdef Plant < handle
    
    properties(Constant)
        
    end
    
    properties
        
        system;
        controller;
        
    end
    
    methods(Abstract)
         
        rollout = run(obj, trajectory)
    end
    
    methods
        
        function obj = Plant(s, c)
            
            obj.system = s;
            obj.controller = c;
        end    
        
        function batch_rollouts = batch_run(obj, batch_trajectories)
            
            batch_rollouts = db.RolloutBatch();
            
            for i = 1:batch_trajectories.size
                disp(strcat('Sample nr : ', num2str(i)));
                ro = obj.run(batch_trajectories.get_rollout(i));
                
                batch_rollouts.append_rollout(ro);
                
                if obj.print_batch
                    obj.print_rollout(ro);
                end
            end
            
        end
        
        function print_rollout(obj, rollout)
            
            figure(obj.handle_batch_figure)
            clf;
            subplot(1,3,1)
            hold on
            plot(rollout.time, rollout.tool_positions(1,:));
            subplot(1,3,2)
            hold on
            plot(rollout.time, rollout.tool_positions(2,:));
            subplot(1,3,3)
            hold on
            plot(rollout.time, rollout.tool_positions(3,:));
        end
     
    end
end

