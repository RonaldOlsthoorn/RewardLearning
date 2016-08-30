% initialize gpml library on MATLAB startup

UR5.startup_UR5;

cd('gpml');
startup_gpml;
cd('..');

currentFolder = pwd;
addpath(currentFolder);