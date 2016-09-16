function [ ref ] = map_ref(ref, model_UR5)

T1 = transl(ref.r_tool(:,1));
T2 = transl(ref.r_tool(:,end));
T = ctraj(T1, T2, length(ref.r_tool(1,:))); 	% compute a Cartesian path
q = model_UR5.ikine(T, 'pinv'); 

figID = 1;
figure(double(figID));
set(double(figID), 'units','normalized','outerposition',[0 0 1 1]);
clf;
model_UR5.plot(q);

T_back_again = model_UR5.fkine(q);

ref.r_joint = q;
ref.r_joint_d = [];
ref.r_joint_dd = [];

end

