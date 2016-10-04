function [agent] = init_agent(agent_par, policy)
% create and initialise the RL agent.
% policy: agents policy parameterization.
% agent_par: tuning parameters agent.


if(strcmp(agent_par.type, 'agent_PI2'))
    
    agent = forward.PI2Agent(agent_par, policy);
end

end

