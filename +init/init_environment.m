function [env] = init_environment(env_par, plant, reward_model, agent)

if env_par.dyn
    expert = expert.HardCodedExpert(env_par.expert_std);
    env = environment.DynamicEnvironment(plant, reward_model, expert, agent, env_par.tol);
else   
    env = environment.StaticEnvironment(plant, reward_model);
end

end