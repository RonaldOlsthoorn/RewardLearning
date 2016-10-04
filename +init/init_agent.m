function [agent] = init_agent(agent_par, policy)

if(strcmp(agent_par.type, 'agent_PI2'))
    
    agent = forward.PI2Agent(agent_par, policy);
end

end

