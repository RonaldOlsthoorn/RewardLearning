function [] = gently_break( arm )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

arm.update();
s = arm.getJointsSpeeds();
arm.setJointsSpeed([0;0;0;0;0;0], 0.5, 1);

tol = 0.001;

while norm(s) > tol
    arm.update();
    pause(0.1)
    s = arm.getJointsSpeeds();

end

