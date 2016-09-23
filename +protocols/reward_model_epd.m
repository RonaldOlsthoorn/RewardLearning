function [rm_par] = reward_model_epd()
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

rm_par.n_segments = 4;
rm_par.improve_tol = 1e-7;
rm_par.af = 'acquisition_epd';
rm_par.rating_noise = 0;
end

