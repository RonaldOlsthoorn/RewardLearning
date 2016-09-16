clear; close all; clc;

model_UR5 = ik.create_model_UR5();

homogen = [0;0;0;1];

qstart = [0;-2*pi/3;2*pi/3;0;pi/2;0];
qend = [0;-1.5935;1.7393;-0.1464;1.5727;0];

tool_start = model_UR5.fkine(qstart)*homogen;
tool_end =  model_UR5.fkine(qend)*homogen;

figID = 1;
figure(double(figID));
set(double(figID), 'units','normalized','outerposition',[0 0 1 1]);
clf;
model_UR5.plot(qstart');

figID = 2;
figure(double(figID));
set(double(figID), 'units','normalized','outerposition',[0 0 1 1]);
clf;
model_UR5.plot(qend');

