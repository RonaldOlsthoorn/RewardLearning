% initialize gpml library on MATLAB startup

cd('gpml');
run('startup.m');
cd('..')

currentFolder = pwd;
addpath(currentFolder);