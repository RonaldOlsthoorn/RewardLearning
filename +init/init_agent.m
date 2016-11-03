function [agent] = init_agent(agent_par, policy)
% create and initialise the RL agent.
% policy: agents policy parameterization.
% agent_par: tuning parameters agent.

switch agent_par.type
    case 'agent_PI2'
        agent = forward.PI2Agent(agent_par, policy);
    case 'agent_PI2BB'
        agent = forward.PI2AgentBB(agent_par, policy);
    case 'agent_PI2DR'
        agent = forward.PI2AgentDR(agent_par, policy);
    case 'agent_PI2DRLegacy'
        agent = forward.PI2AgentLegacy(agent_par, policy);
    otherwise
        agent = [];
end
end

