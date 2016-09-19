function [ arm ] = init_UR5( )
%INIT_UR5 Summary of this function goes here
% Detailed explanation goes here

arm = UR5.driver.URArm();
% ip = '192.168.1.50';
% arm.fopen(ip);

end

