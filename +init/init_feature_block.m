function [ feature_block ] = init_feature_block( featrure_block_par )
% create and initialise feature block. think this is deprecated as well.

if(strcmp(featrure_block_par, 'SimpleFeatureBlock'))
    feature_block = reward.SimpleFeatureBlock(featrure_block_par);
else
    feature_block = [];
end

end