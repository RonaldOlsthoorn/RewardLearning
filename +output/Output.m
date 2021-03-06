classdef Output < handle
    % OUTPUT. Container class, collecting all relevant result of one run of
    % any SARL protocol.
    
    properties
        
        succeeded = 1;
        
        db_obj;
        rm_obj;
        ref_obj;
        
        db_str;
        rm_str;
        ref_str;
        
        n_init_samples;
        reps;
        n_reuse;
        iteration = 0;
        
        n_rollouts;
        
        Demo_trace;
        Reward_trace;
        Weight_trace;
        
        dynamic;
        manual;
        granularity;
    end
    
    methods
        
        % Collect reward and trajectory information per iteration. needs to
        % be called every iteration of the algorithm to work (needless
        % coupling).
        % rm: reward model (needed for demo trace).
        % nr: noiseless rollout (needed for trajectory trace).
        function tick(obj, rm, nr)
            
            obj.iteration = obj.iteration + 1;
            obj.process_reward_trace(nr);
            obj.process_demo_trace(rm);
            obj.process_weight_trace(nr);
        end
        
        % Sometimes, algorithms fail (singularity problems). If this the 
        % case, use it for statistics.
        function set_to_failed(obj)
            obj.succeeded = 0;
        end
        
        % Collect information regarding demonstrations.
        function process_demo_trace(obj, rm)
            
            if obj.dynamic
                
                if strcmp(obj.granularity, 'single')
                    
                    l = length(obj.Demo_trace);
                    
                    if l<rm.batch_demonstrations.size
                        
                        for i = (l+1):rm.batch_demonstrations.size
                            
                            demo_obj = rm.batch_demonstrations.get_rollout(i);
                            demo_str = demo_obj.to_struct();
                            demo_str.iteration_queried = obj.iteration;
                            
                            if isempty(obj.Demo_trace)
                                obj.Demo_trace = demo_str;
                            else
                                obj.Demo_trace(end+1) = demo_str;
                            end
                        end
                    end
                    
                elseif strcmp(obj.granularity, 'multi')
                    
                    for i = 1:4
                        
                        if isempty(obj.Demo_trace)
                            l = 0;
                        elseif i>length(obj.Demo_trace)
                            l = 0;
                        else
                            l = length(obj.Demo_trace{i});
                        end
                        
                        if l<rm.db_demo(i).size
                            
                            for j = (l+1):rm.db_demo(i).size
                                demo_obj = rm.db_demo(i).get_rollout(j);
                                demo_str = demo_obj.to_struct();
                                demo_str.iteration_queried = obj.iteration;
                                
                                if isempty(obj.Demo_trace)
                                    obj.Demo_trace{i} = demo_str;
                                elseif i>length(obj.Demo_trace)
                                    obj.Demo_trace{i} = demo_str;
                                else
                                    obj.Demo_trace{i}(end+1) = demo_str;
                                end
                            end
                        end
                    end
                end
            end
        end
        
        % Collect reward convergence information.
        % noiseless_rollout: noiseless rollout (containing its reward)
        function process_reward_trace(obj, noiseless_rollout)
            
            if isempty(obj.Reward_trace)
                obj.Reward_trace = noiseless_rollout.to_struct();
            else
                obj.Reward_trace(end+1) = noiseless_rollout.to_struct();
            end
        end
        
        % Collect policy information
        function process_weight_trace(obj, noiseless_rollout)
            
            for i = 1:length(noiseless_rollout.policy.dof)
                obj.Weight_trace(obj.iteration,i,:) = noiseless_rollout.policy.dof(i).theta_eps(1,:);
            end
            
        end
        
        % Calculates number of rollouts each iteration.
        function trace_rollouts(obj)
            if obj.iteration == 1
                obj.n_rollouts(1,1) = obj.n_init_samples;
            elseif obj.iteration == 2
                obj.n_rollouts(2,1) = obj.n_rollouts(1,1) + obj.reps;
            else
                n_start = length(obj.n_rollouts(:,1));
                
                obj.n_rollouts(n_start + 1, 1) = obj.n_rollouts(n_start) + (obj.reps - obj.n_reuse);
            end
        end
        
        % Called after algorithm completes. Saves complete set of rollouts.
        function process_final_db(obj, db)
            
            obj.db_obj = db;
            obj.db_str = db.to_struct();
        end
        
        % Called after algorithm completes. Store reference info.
        function process_final_ref(obj, ref)
            
            obj.ref_obj = ref;
            obj.ref_str = ref.to_struct();
        end
        
        % Called after algorithm completes. Store final reward model (used for plotting).
        function process_final_rm(obj, rm)
            
            obj.rm_obj = rm;
            obj.rm_str = rm.to_struct();
        end
        
        % Print final reward function.
        function print_reward(obj)
            
            obj.rm_obj.print();
        end
        
        % Print several important plots.
        function res = print(obj)
            
            % print all trajectories
            figHandle = figure;
            
            subplot(1,3,1)
            xlabel('time [s]');
            ylabel('x end effector [m]');
            
            subplot(1,3,2)
            xlabel('time [s]');
            ylabel('y end effector [m]');
            
            subplot(1,3,3)
            xlabel('y end effector [m]');
            ylabel('y end effector [m]');
            
            n_iterations = length(obj.Reward_trace);
 
            % print all trajectories
            for i = 1:n_iterations
                
                if i == 1
                    color = [0.5, 0.5, 0.5];
                    
                else
                    color =  [  1-(i/n_iterations)^2, ...
                        1-(i/n_iterations)^2, ...
                        1  ];
                end
                
                rollout = obj.Reward_trace(i);
                
                subplot(1,3,1)
                hold on;
                plot(rollout.time, rollout.tool_positions(1,:), ...
                    'Color', color);
                
                subplot(1,3,2)
                hold on;
                plot(rollout.time, rollout.tool_positions(2,:), ...
                    'Color', color);
                
                subplot(1,3,3)
                hold on;
                plot(rollout.tool_positions(1,:), rollout.tool_positions(2,:), ...
                    'Color', color);
            end
            
            %print final mark viapoint
            subplot(1,3,3)
            hold on;
            scatter(obj.Reward_trace(end).tool_positions(1,obj.ref_obj.viapoints_t),...
                obj.Reward_trace(end).tool_positions(2,obj.ref_obj.viapoints_t),...
                40, 'Marker', '+', 'LineWidth', 2, ...
                'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'r');
            
            obj.ref_obj.clear_overlay_handles();
            obj.ref_obj.print_reference_overlay(figHandle);
            
            % print first and last rollout
            figHandle = figure;
            
            subplot(1,3,1);
            hold on;
            plot(obj.Reward_trace(1).time, obj.Reward_trace(1).tool_positions(1,:), ...
                'Color', [0.5, 0.5, 0.5]);
            plot(obj.Reward_trace(end).time, obj.Reward_trace(end).tool_positions(1,:), ...
                'Color', [0, 0, 1]);
            
            xlabel('time [s]');
            ylabel('x end effector [m]');
            
            subplot(1,3,2);
            hold on;
            plot(obj.Reward_trace(1).time, obj.Reward_trace(1).tool_positions(2,:), ...
                'Color', [0.5, 0.5, 0.5]);
            plot(obj.Reward_trace(end).time, obj.Reward_trace(end).tool_positions(2,:), ...
                'Color', [0, 0, 1]);
            xlabel('time [s]');
            ylabel('y end effector [m]');
            
            subplot(1,3,3);
            hold on;
            plot(obj.Reward_trace(1).tool_positions(1,:), obj.Reward_trace(1).tool_positions(2,:), ...
                'Color', [0.5, 0.5, 0.5]);
            plot(obj.Reward_trace(end).tool_positions(1,:), obj.Reward_trace(end).tool_positions(2,:), ...
                'Color', [0, 0, 1]);
            scatter(obj.Reward_trace(end).tool_positions(1,obj.ref_obj.viapoints_t),...
                obj.Reward_trace(end).tool_positions(2,obj.ref_obj.viapoints_t),...
                40, 'Marker', '+', 'LineWidth', 2, ...
                'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'r');
            
            xlabel('y end effector [m]');
            ylabel('y end effector [m]');
            
            obj.ref_obj.clear_overlay_handles();
            obj.ref_obj.print_reference_overlay(figHandle);
            
            % save important info for summary
            res.first_rollout = obj.Reward_trace(1)
            
            
            % reward plots
            if strcmp(obj.granularity, 'multi')
                obj.rm_obj.print();
            end
            
            if obj.manual
                
                
                if strcmp(obj.granularity, 'single')
                    l = length(obj.Demo_trace);
                    D = zeros(l, 2);
                    
                    for i = 1:length(obj.Demo_trace)
                        
                        D(i,1) = obj.Demo_trace(i).iteration_queried;
                        D(i,2) = obj.Demo_trace(i).R_expert;
                    end
                    
                    R = zeros(1,n_iterations);
                    
                    for i = 1:n_iterations
                        
                        R(i) = obj.Reward_trace(i).R;
                    end
                    
                    figure
                    title('expert rating convergence');
                    hold on;
                    scatter(D(:,1), D(:,2));
                    plot(R);
                    xlabel('iteration');
                    ylabel('return');
                    
                    legend('expert return', 'reward model return',...
                        'location', 'southeast');
                    
                else
                    
                    R = zeros(n_iterations-1, 4);
                    
                    for i = 1:4
                        
                        l = length(obj.Demo_trace{i});
                        d = zeros(l,2);
                        
                        for j = 1:l
                            
                            d(j,1) = obj.Demo_trace{i}(j).iteration_queried;
                            d(j,2) = obj.Demo_trace{i}(j).R_expert(i);
                        end
                        
                        D{i} = d;
                        
                        for j = 1:(n_iterations-1)
                            
                            if ~ isfield(obj.Reward_trace(j), 'R_segments')
                                R(j,:) = [0 obj.Reward_trace(j).R 0 0];
                            else
                                
                                R(j,i) = obj.Reward_trace(j).R_segments(i);
                            end
                        end
                        
                    end
                    
                    figure
                    title('expert rating convergence');
                    hold on;
                    scatter(D{2}(:,1), D{2}(:,2));
                    plot(R(:,2));
                    xlabel('iteration');
                    ylabel('return');
                    
                    legend('expert return', 'reward model return',...
                        'location', 'southeast');
                    
                    figure
                    suptitle('expert rating convergence');
                    
                    subplot(2,2,1)
                    hold on;
                    scatter(D{1}(:,1), D{1}(:,2));
                    plot(R(:,1));
                    xlabel('iteration');
                    ylabel('return');
                    title(strcat('segment',' 1'));
                    legend('expert return', 'reward model return',...
                        'location', 'southeast');
                    
                    subplot(2,2,2)
                    hold on;
                    scatter(D{2}(:,1), D{2}(:,2));
                    plot(R(:,2));
                    xlabel('iteration');
                    ylabel('return');
                    title(strcat('segment',' 2'));
                    legend('expert return', 'reward model return',...
                        'location', 'southeast');
                    
                    subplot(2,2,3)
                    hold on;
                    scatter(D{3}(:,1), D{3}(:,2));
                    plot(R(:,3));
                    xlabel('iteration');
                    ylabel('return');
                    title(strcat('segment',' 3'));
                    legend('expert return', 'reward model return',...
                        'location', 'southeast');
                    
                    subplot(2,2,4)
                    hold on;
                    scatter(D{4}(:,1), D{4}(:,2));
                    plot(R(:,4));
                    xlabel('iteration');
                    ylabel('return');
                    title(strcat('segment',' 4'));
                    legend('expert return', 'reward model return',...
                        'location', 'southeast');
                    
                end
                
            else
                
                n_iterations = length(obj.Reward_trace);
                R = zeros(1,n_iterations);
                R_true = zeros(1,n_iterations);
                
                for i = 1:n_iterations
                    
                    R(i) = obj.Reward_trace(i).R;
                    R_true(i) = obj.Reward_trace(i).R_true;
                end
                
                figure
                hold on;
                plot(R);
                plot(R_true);
                xlabel('iteration')
                ylabel('return')
                title('Convergence')
                legend('reward model return', 'true return',...
                    'location', 'southeast');
                
            end
        end
        
        % Collect all information in a single struct (MATLAB cannot save objects)
        function res = to_struct(obj)
            
            res.db = obj.db_str;
            res.ref = obj.ref_str;
            res.rm = obj.rm_str;
            res.Reward_trace = obj.Reward_trace;
            res.Demo_trace = obj.Demo_trace;
            res.Weight_trace = obj.Weight_trace;
            res.manual = obj.manual;
            res.granularity = obj.granularity;
            res.dynamic = obj.dynamic;
        end
    end
    
    methods(Static)
        
        % Generate object from struct
        function obj = from_struct(struct)
            
            obj = output.Output();
            
            obj.manual = struct.manual;
            obj.granularity = struct.granularity;
            obj.dynamic = struct.dynamic;
            
            obj.Reward_trace = struct.Reward_trace;
            obj.Demo_trace = struct.Demo_trace;
            obj.Weight_trace = struct.Weight_trace;
            
            obj.db_obj = db.DB.from_struct(struct.db);
            
            switch struct.ref.type
                case 'VPReference'
                    obj.ref_obj = refs.VPReference(struct.ref);
                case 'VPAdvancedReference'
                    obj.ref_obj = refs.VPAdvancedReference(struct.ref);
            end
            
            switch struct.rm.type
                case 'VPSingleGPRewardModel'
                    obj.rm_obj = reward.VPSingleGPRewardModel.from_struct(struct.rm);
                case 'VPMultiGPRewardModel'
                    obj.rm_obj = reward.VPMultiGPRewardModel.from_struct(struct.rm);
                case 'VPVarSingleGPRewardModel'
                    obj.rm_obj = reward.VPVarSingleGPRewardModel.from_struct(struct.rm);
                case 'VPVarMultiGPRewardModel'
                    obj.rm_obj = reward.VPVarMultiGPRewardModel.from_struct(struct.rm);
            end
        end
    end
end