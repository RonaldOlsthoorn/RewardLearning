function [r_joints, r_joints_d, r_joints_dd] = map_ref(r_tool, start_joint, Ts, model_UR5)
% r_tool: trajectory in cartesian tool space. represented as
% [x;y;z;rx;ry;rz] (axis angle representation).
% ref_par: struct containing guess initial position in joint space and
% sampling time Ts.
% model_UR5: Link representation of the UR5_model.


q = zeros(6, length(r_tool(1,:)));
q(:, 1) = model_UR5.ikine(transl(r_tool(:,1)), start_joint);  

for i = 2:length(r_tool(1,:))
    
    T = transl(r_tool(:,i));
    qi = model_UR5.ikine(T, q(:,i-1));   
    q(:, i)= qi';
end

r_joints = q;
r_joints_d = [zeros(6, 1) diff(r_joints, 1, 2)/Ts];
r_joints_dd = [zeros(6, 1) diff(r_joints_d, 1, 2)/Ts];

