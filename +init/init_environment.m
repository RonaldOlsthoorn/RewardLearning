function [env] = init_environment(env_par, plant, reward_model, agent, ref)

if env_par.dyn
    switch env_par.expert
        case 'hard_coded_expert'
            ex = expert.HardCodedExpert(env_par.expert_std);
        case 'multi_segment_expert'
            ex = expert.MultiSegmentExpert(env_par.expert_std, reward_model.n_segments);
        case 'vp_multi_segment_expert'
            ex = expert.VPMultiSegmentExpert(env_par.expert_std, ref, reward_model.n_segments);
        case 'vp_single_segment_expert'
            ex = expert.VPSingleSegmentExpert(env_par.expert_std, ref);
        case 'manual_expert'
            ex = expert.ManualExpert(ref, reward_model.n_segments);
        case 'manual_expert_segmented'
            ex = expert.ManualExpertSegmented(ref, reward_model.n_segments);
        case 'manual_advanced_expert'
            ex = expert.ManualAdvancedExpert(ref, reward_model.n_segments);
        case 'manual_advanced_expert_segmented'
            ex = expert.ManualAdvancedExpertSegmented(ref, reward_model.n_segments);
        case 'vp_advanced_multi_segment_expert'
            ex = expert.VPAdvancedMultiSegmentExpert(env_par.expert_std, ref, reward_model.n_segments);
        case 'vp_advanced_single_segment_expert'
            ex = expert.VPAdvancedSingleSegmentExpert(env_par.expert_std, ref);        
        otherwise
            ex = [];
    end
        
    switch env_par.acquisition
        case 'epd_single'
            env = environment.SingleSegmentEnvironment(plant, reward_model, ex, agent);
        case 'epd_multi'
            env = environment.MultiSegmentEnvironment(plant, reward_model, ex, agent);
        otherwise
            env = [];
    end
    
    env.tol = env_par.tol;
else   
    env = environment.StaticEnvironment(plant, reward_model);
end

end