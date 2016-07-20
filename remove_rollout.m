function [ S ] = remove_rollout( S, index )

for i=1:length(S.rollouts)
    
    if S.rollouts(i).index==index
        
        if i==1
            S.rollouts = S.rollouts(2:end);
        elseif i==length(S.rollouts)
            S.rollouts = S.rollouts(1:(end-1));
        else
            ro = [S.rollouts(1:(i-1)) S.rollouts((i+1):end)];
            S.rollouts = ro;
        end
        
        break;
    end
        
end

