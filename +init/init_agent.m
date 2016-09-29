function [agent] = init_agent(agent_par, policy)

if(strcmp(agent_par.type, 'agent_PI2'))
    
    agent = forward.PI2Agent(policy);
end

end

