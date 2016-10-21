classdef Plant < handle
    
    properties(Constant)
        
    end
    
    properties
        
        system;
        controller;
        print_batch = true;
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
            
            if obj.print_batch
                obj.reset_figure();
            end
            
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
        
        function reset_figure(obj)
            
            figure(obj.handle_batch_figure);
            set(double(obj.handle_batch_figure),...
                'units','normalized','outerposition',[0 0 1 1]);
            clf;

        end
        
    end
end

