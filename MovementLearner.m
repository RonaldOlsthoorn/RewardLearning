classdef MovementLearner < handle
    % God class handling the complete active reward learning algorhithm.
    
    properties(Constant)
        
        handle_cost_figure = 5;
        handle_noiseless_figure = 2;
    end
    
    properties
        
        protocol_s;
        
        W; % policy weight trace
        R; % Reward trace
        R_true;
        
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
            obj.R_true = [];
            
            
            protocol_handle = str2func(strcat('protocols.', obj.protocol_s));
            protocol = protocol_handle();
            obj.init_learner(protocol);
            
            obj.db = db.DB();
        end
        
        function init_learner(obj, p)
            
            import plant.Plant;
            import environment.Environment;
            
            rng(20); % fix random seed. handy for comparisson
            
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
            
            iteration = 1;
            
            obj.environment.prepare();
            
            while iteration < 50 % for now. Replace with EPD
                
                obj.print_progress();
                
                batch_trajectory = obj.agent.get_batch_trajectories();
                batch_rollouts = obj.environment.batch_run(batch_trajectory);
                obj.db.append_row(batch_rollouts);
                batch_rollouts = obj.agent.mix_previous_rollouts(batch_rollouts);
                
                obj.environment.update_reward(batch_rollouts)
                
                obj.agent.update(batch_rollouts);
                
                iteration = iteration + 1;
            end
            
            Weights = obj.W;
            Returns = obj.R;
            
            obj.print_result();
        end
        
        function print_progress(obj)
            
            noiseless_trajectory = obj.agent.get_noiseless_trajectory();
            noiseless_rollout = obj.environment.run(noiseless_trajectory);
            rating = obj.environment.expert.query_expert(noiseless_rollout);
            
            obj.print_noiseless_rollout(noiseless_rollout);
            
            obj.R = [obj.R noiseless_rollout.R];
            obj.R_true = [obj.R_true sum(rating)];
        end
        
        function print_result(obj)
            
            noiseless_trajectory = obj.agent.get_noiseless_trajectory();
            disp('Noiseless rollout');
            noiseless_rollout = obj.environment.run(noiseless_trajectory);
            obj.print_noiseless_rollout(noiseless_rollout);
            
            figure;
            hold on;
            plot(obj.R);
            plot(obj.R_true);
            title(obj.protocol_s);
            xlabel('iteration');
            ylabel('Return');
        end
        
        function print_noiseless_rollout(obj, rollout)
            % print the noiseless rollout in a single figure.
            
            disp(strcat('Return: ', num2str(rollout.R)));
            obj.plant.print_rollout(rollout);
        end
        
        function reset_figure(obj)
            
            figure(obj.handle_noiseless_figure);
            set(double(obj.handle_noiseless_figure),...
                'units','normalized','outerposition',[0 0 1 1]);
            clf;
            
            subplot(1,3,1)
            xlabel('t [s]');
            ylabel('x_{ef} [m]');
            
            subplot(1,3,2)
            xlabel('t [s]');
            ylabel('y_{ef} [m]');
            
            subplot(1,3,3)
            xlabel('x_{ef} [m]');
            ylabel('y_{ef} [m]');
            
            drawnow;
        end
    end
end