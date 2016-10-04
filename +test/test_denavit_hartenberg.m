function [model_UR5, T, u] = test_denavit_hartenberg(input)

mdl_UR5;

corrected_input = input;
corrected_input(2) = corrected_input(2);
corrected_input(4) = corrected_input(2);

T = model_UR5.fkine(corrected_input);
u = T*[0;0;0;1];

figID = 1;
figure(double(figID));
set(double(figID), 'units','normalized','outerposition',[0 0 1 1]);
clf;
model_UR5.plot(corrected_input);