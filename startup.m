% initialize gpml library on MATLAB startup
cd('gpml');
startup_gpml;
cd('..');

cd('rvctools');
startup_rvc;
cd('..');

currentFolder = pwd;
addpath(currentFolder);