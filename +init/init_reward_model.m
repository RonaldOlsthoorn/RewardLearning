function [ reward_model ] = init_reward_model( reward_model_par )

if(strcmp(reward_model_par.type, 'static_lin'))
    reward_model = reward.StaticLinearRewardModel();
else
    reward_model = [];
end



end


