classdef MovementLearner < handle
    % God class handling the complete active reward learning algorhithm.
    
    properties(Constant)
        
        handle_cost_figure = 5;
        handle_noiseless_figure = 2;
    end
    
    properties
        
        W; % policy weight trace
        R; % Reward trace
        
        plant;
        
        reward_model;
        environment;
        
        reference;

        agent;
    end
    
    methods
        
        function obj = MovementLearner(protocol)
            
            obj.W = [];
            obj.R = [];
            
            protocol_handle = str2func(strcat('protocols.', protocol));
            protocol = protocol_handle();
            obj.init_learner(protocol);        
        end
        
        function init_learner(obj, p)    
            
            import plant.Plant;
            import environment.Environment;
                        
            controller = init.init_controller(p.controller_par);          
            obj.plant = init.init_plant(p.plant_par, controller);
            
            obj.reference = init.init_reference(p.reference_par);

            obj.reward_model = init.init_reward_model(p.reward_model_par,...
                                                        obj.reference);
            
            obj.environment = Environment(obj.plant, obj.reward_model);
          
            policy = init.init_policy(p.policy_par, obj.reference);
            
            obj.agent = init.init_agent(p.agent_par, policy);
        end
        
        function [Weights, Returns] = run_movement_learning(obj)
            
            iteration = 1;
            
            while iteration<100; % for now. Replace with EPD
                
                batch_trajectory = obj.agent.get_batch_trajectories();
                batch_rollouts = obj.environment.batch_run(batch_trajectory);
                batch_rollouts = obj.agent.mix_previous_rollouts(batch_rollouts);
                
                % obj.environment.reward_model.update(batch_rollout)
                
                noiseless_trajectory = obj.agent.get_noiseless_trajectory();
                noiseless_rollout = obj.environment.run(noiseless_trajectory);
                
                obj.print_noiseless_rollout(noiseless_rollout);       
                
                obj.agent.update(batch_rollouts);
                
                iteration = iteration + 1;
            end
                        
            Weights = obj.W;
            Returns = obj.R;
        end
        
        function print_noiseless_rollout(obj, rollout)
            % print the noiseless rollout in a single figure.
            
            disp(strcat('Return: ', num2str(rollout.R))); 
            figure(obj.handle_noiseless_figure)
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

