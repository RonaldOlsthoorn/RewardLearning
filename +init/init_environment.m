function [env] = init_environment(env_par, plant, reward_model, agent, ref)

if env_par.dyn
    switch env_par.expert
        case 'hard_coded_expert'
            ex = expert.HardCodedExpert(env_par.expert_std);
        case 'multi_segment_expert'
            ex = expert.MultiSegmentExpert(env_par.expert_std, reward_model.n_segments);
        case 'vp_multi_segment_expert'
            ex = expert.VPMultiSegmentExpert(env_par.expert_std, ref, reward_model.n_segments);
        otherwise
            ex = [];
    end
    env = environment.DynamicEnvironment(plant, reward_model, ex, agent, env_par.tol);
    env.acquisition = env_par.acquisition;
else   
    env = environment.StaticEnvironment(plant, reward_model);
end

end