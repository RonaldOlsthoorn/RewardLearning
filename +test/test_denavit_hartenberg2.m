mdl_UR5;

load('+output/data.mat');

for i = 1:5

input = data.joints(:,i);

T = model_UR5.fkine(input);

u = T*[0;0;0;1]
data.tool(:,i)

figID = 1;
figure(double(figID));
set(double(figID), 'units','normalized','outerposition',[0 0 0.5 0.5]);
clf;
model_UR5.plot(input');

end