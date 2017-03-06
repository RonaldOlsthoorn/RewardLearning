classdef MovementLearner < handle
    % God class handling the complete active reward learning algorhithm.
    
    properties(Constant)
        
        handle_cost_figure = 5;
        handle_noiseless_figure = 2;
    end
    
    properties
        
        iteration;
        totalIt = 50;
        protocol_s;
        
        W; % policy weight trace
        R; % Reward trace
        D;
        R_true;
        R_expert;
        n_rollouts;
        
        plant;
        
        reward_model;
        environment;
        
        reference;
        
        agent;
        
        db;
    end
    
    methods
        
        function obj = MovementLearner(p)
            
            obj.protocol_s = p;
            
            obj.W = [];
            obj.R = [];
            obj.R_expert = [];
            obj.R_true = [];
            
            protocol_handle = str2func(strcat('protocols.', obj.protocol_s));
            protocol = protocol_handle();
            obj.init_learner(protocol);
            
            obj.db = db.DB();
        end
        
        function init_learner(obj, p)
            
            import plant.Plant;
            import environment.Environment;
            
            rng(20); % fix random seed. handy for comparisson.
            % Set seed 1 for total shitstorm on advancedx_single
            % or nice result on advanced_var_multi
            % Set seed 3 for decent result on advancedx_single.
            % Set seed 20 for rest.
            
                       
            obj.reference = init.init_reference(p.reference_par);
            obj.plant = init.init_plant(p.plant_par, p.controller_par);
            obj.plant.set_init_state(obj.reference.init_state);
            
            policy = init.init_policy(p.policy_par, obj.reference);
            obj.agent = init.init_agent(p.agent_par, policy);
            
            obj.reward_model = init.init_reward_model(p.reward_model_par,...
                obj.reference);
            
            obj.environment = init.init_environment(p.env_par, ...
                obj.plant, obj.reward_model, obj.agent, obj.reference);
        end
        
        function [Weights, Returns] = run_movement_learning(obj)
            
            obj.iteration = 1;
            
            obj.environment.prepare();
            
            while obj.iteration < obj.totalIt % for now. Replace with EPD
                
                obj.print_progress();
                
                batch_trajectory = obj.agent.get_batch_trajectories();
                batch_rollouts = obj.environment.batch_run(batch_trajectory);
                obj.db.append_row(batch_rollouts);
                batch_rollouts = obj.agent.mix_previous_rollouts(batch_rollouts);
                
                obj.environment.update_reward(batch_rollouts)
                
                obj.agent.update(batch_rollouts);
                
                obj.iteration = obj.iteration + 1;
            end
            
            Weights = obj.W;
            Returns = obj.R;
            
            obj.print_result();
        end
        
        function print_progress(obj)
            
            noiseless_trajectory = obj.agent.get_noiseless_trajectory();
            noiseless_rollout = obj.environment.run(noiseless_trajectory);
            
            trace_rollouts(obj);
            
            if isa(obj.environment,'environment.DynamicEnvironment')
   
                if isa(obj.reward_model, 'reward.VPSingleGPRewardModel') ||...
                        isa(obj.reward_model, 'reward.VPVarSingleGPRewardModel')
                       
                    if obj.iteration == 1
                        obj.D(1,1) = obj.reward_model.batch_demonstrations.size;
                    else
                        obj.D(end + 1, 1) = obj.reward_model.batch_demonstrations.size;
                    end
                    
                elseif isa(obj.reward_model, 'reward.VPMultiGPRewardModel') ||...
                        isa(obj.reward_model, 'reward.VPVarMultiGPRewardModel')
                    
                    if obj.iteration == 1
                        
                        d = 0;
                        for i = 1:length(obj.reward_model.db_demo)
                            d = d + obj.reward_model.db_demo(i).size;
                        end

                        obj.D(1,1) = d; 
                    else
                        d = 0;
                        for i = 1:length(obj.reward_model.db_demo)
                            d = d + obj.reward_model.db_demo(i).size;
                        end
                            
                        obj.D(end + 1,1) = d;
                    end
                end
                
                if obj.environment.expert.manual == false
                    rating_expert = obj.environment.expert.query_expert(noiseless_rollout);
                end
                rating_true = obj.environment.expert.true_reward(noiseless_rollout);
            else
                rating_true = noiseless_rollout.R;
            end
            
            obj.print_noiseless_rollout(noiseless_rollout);
            
            if isa(obj.environment, 'environment.DynamicEnvironment')
                if obj.environment.expert.manual == false
                    obj.R_expert = [obj.R_expert sum(rating_expert)];
                end
            end
            
            obj.R = [obj.R noiseless_rollout.R];
            obj.R_true = [obj.R_true sum(rating_true)];
        end
        
        function print_result(obj)
            
            noiseless_trajectory = obj.agent.get_noiseless_trajectory();
            disp('Noiseless rollout');
            noiseless_rollout = obj.environment.run(noiseless_trajectory);
            obj.print_noiseless_rollout(noiseless_rollout);
            
            figure;
            hold on;
            
            if isa(obj.environment,'environment.DynamicEnvironment')
                
                plot(obj.n_rollouts, obj.R);
                plot(obj.n_rollouts, obj.R_expert);
                %plot(obj.n_rollouts, obj.R_true);
                
                dataY = [1 diff(obj.D)'];
                dataY(dataY ~= 0) = 1;
                dataY = dataY.*obj.R_expert;
                data = [obj.n_rollouts'; dataY];
                data( :, ~any(data(2,:),1) ) = [];
                
                scatter(data(1,:), data(2,:));

                disp(strcat('number of queries: ', num2str(obj.environment.n_queries)));
            else
                plot(obj.n_rollouts, obj.R);
            end
            
            title(strrep(obj.protocol_s, '_', ' '));
            xlabel('rollouts');
            ylabel('Return');
            
            figure;
            plot(obj.n_rollouts, obj.D);
            title(strrep(obj.protocol_s, '_', ' '));
            xlabel('rollouts');
            ylabel('expert queries');
        end
        
        function print_noiseless_rollout(obj, rollout)
            % print the noiseless rollout in a single figure.
            
            disp(strcat('Return: ', num2str(rollout.R)));
            obj.plant.print_rollout(rollout, obj.reference, obj.totalIt, obj.iteration);
        end
        
        function trace_rollouts(obj)
            if obj.iteration == 1
                obj.n_rollouts(1,1) = obj.environment.n_init_samples;
            elseif obj.iteration == 2
                obj.n_rollouts(2,1) = obj.n_rollouts(1,1) + obj.agent.reps;
            else
                n_start = length(obj.n_rollouts(:,1));
                
                obj.n_rollouts(n_start + 1, 1) = obj.n_rollouts(n_start) + (obj.agent.reps - obj.agent.n_reuse);
            end
        end
        
        function reset_figure(obj)
            
            figure(obj.handle_noiseless_figure);
            set(double(obj.handle_noiseless_figure),...
                'units', 'normalized', 'outerposition', [0 0 1 1]);
            clf;
            
            subplot(1, 3, 1);
            xlabel('t [s]');
            ylabel('x_{ef} [m]');
            
            subplot(1, 3, 2);
            xlabel('t [s]');
            ylabel('y_{ef} [m]');
            
            subplot(1, 3, 3);
            xlabel('x_{ef} [m]');
            ylabel('y_{ef} [m]');
            
            drawnow;
        end
        
        function res = export(obj)
            
            res.reward_model = obj.reward_model.to_struct();
            
            noiseless_trajectory = obj.agent.get_noiseless_trajectory();
            noiseless_rollout = obj.environment.run(noiseless_trajectory);
            
            res.final_rollout = noiseless_rollout.to_struct();
            
            if isa(obj.environment,'environment.DynamicEnvironment')
                
                res.R = obj.R;
                res.R_expert = obj.R_expert;
                res.n_queries = obj.environment.n_queries;
            else
                res.R = obj.R;
            end
            
        end
    end
end