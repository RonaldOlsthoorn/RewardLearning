classdef MovementLearner < handle
    
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
            
            W = [];
            R = [];
            
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
            obj.reward_model = init.init_reward_model(reward_model_par);
            
            obj.environment = Environment(obj.plant, obj.reward_model);
          
            policy_protocol = str2func(strcat('protocols.', p.policy)); 
            policy_par = policy_protocol();
            obj.policy = init.init_policy(policy_par, obj.reference);
            
            agent_protocol = str2func(strcat('protocols.', p.agent)); 
            agent_par = agent_protocol();
            obj.agent = init.init_agent(agent_par, obj.policy);
        end
        
        function [W, R] = run_movement_learning(obj)
            
            iteration = 1;
            
            while converged(iteration)
                
                batch_trajectory = obj.agent.batch_create_trajectory();
                batch_rollout = obj.environment.batch_run(batch_trajectory);
                
                % obj.environment.reward_model.update(batch_rollout)
                
                obj.agent.update(batch_rollout);
                
                noiseless_rollout = obj.agent.create_noiseless_rollout();
                noiseless_rollout.print();                
                
                iteration = iteration +1;
            end
            
            obj.print_result();
        end
        
        function print_result(obj)
            
        end
    end
    
end

