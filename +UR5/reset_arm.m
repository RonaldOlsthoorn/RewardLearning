function [ pos ] = reset_arm(arm)

tolerance = 0.001;

pos0 = [0; -2*pi/3; 2*pi/3; 0; pi/2; 0];  

arm.update();
pos = arm.getJointsPositions();

for i = 1:6
pos(i) = pos0(i);

arm.moveJoints(pos);
pos = arm.getJointsPositions();

while abs(pos(i)-pos0(i)) > tolerance
    
    pause(1)
    arm.update();
    pos = arm.getJointsPositions();
end

end