classdef MovementLearner < handle
    
    properties(Constant)
        
        handle_cost_figure = 5;
        handle_noiseless_figure = 2;

    end
    
    properties
        
        W;
        R;
        
        system;
        controller;
        plant;
        
        reward_model;
        environment;
        
        reference;
        
        policy;
        agent;
    end
    
    methods
        
        function obj = MovementLearner(protocol)
            
            obj.W = [];
            obj.R = [];
            
            p = init.read_protocol(protocol);
            obj.init_learner(p);
            
        end
        
        function init_learner(obj, p)    
            
            import plant.Plant;
            import environment.Environment;
            
            system_protocol = str2func(strcat('protocols.', p.system)); 
            system_par = system_protocol();
            obj.system = init.init_system(system_par);
            
            controller_protocol = str2func(strcat('protocols.', p.controller)); 
            controller_par = controller_protocol();
            obj.controller = init.init_controller(controller_par);
            
            obj.plant = Plant(obj.system, obj.controller);
            
            reference_protocol = str2func(strcat('protocols.', p.reference)); 
            reference_par = reference_protocol();
            obj.reference = init.init_reference(reference_par);

            reward_model_protocol = str2func(strcat('protocols.', p.reward_model)); 
            reward_model_par = reward_model_protocol();
            obj.reward_model = init.init_reward_model(reward_model_par, obj.reference);
            
            obj.environment = Environment(obj.plant, obj.reward_model);
          
            policy_protocol = str2func(strcat('protocols.', p.policy)); 
            policy_par = policy_protocol();
            obj.policy = init.init_policy(policy_par, obj.reference);
            
            agent_protocol = str2func(strcat('protocols.', p.agent)); 
            agent_par = agent_protocol();
            obj.agent = init.init_agent(agent_par, obj.policy);
        end
        
        function [Weights, Returns] = run_movement_learning(obj)
            
            iteration = 1;
            
            while iteration<100;
                
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

