function [S] = map_ref(S, dmp_par, model_UR5)

q = zeros(6, length(S.ref.r_tool(1,:)));
q(:, 1) = model_UR5.ikine(transl(S.ref.r_tool(:,1)), dmp_par.start_joint);  

for i = 2:length(S.ref.r_tool(1,:))
    
    T = transl(S.ref.r_tool(:,i));
    qi = model_UR5.ikine(T, q(:,i-1));   
    q(:, i)= qi';
    i
end

% figID = 1;
% figure(double(figID));
% set(double(figID), 'units','normalized','outerposition',[0 0 1 1]);
% clf;
% model_UR5.plot(q');

S.ref.r_joint = q;
S.ref.r_joint_d = [zeros(6, 1) diff(S.ref.r_joint, 1, 2)/dmp_par.Ts];
S.ref.r_joint_dd = [zeros(6, 1) diff(S.ref.r_joint_d, 1, 2)/dmp_par.Ts];
