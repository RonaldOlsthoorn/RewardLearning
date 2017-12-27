function [j, jd, jdd] = map_ref2(r_tool, x0, Ts, par)
% Maps reference from ef space to joint space (2Dof).

j = zeros(2, length(r_tool(1,:)));
j(:,1) = x0;

for i=2:length(r_tool(1,:))
    
    j(:,i) = ik.ik_jac(j(:,i-1), r_tool(:,i), par);
end

jd = [[0; 0] [diff(j(1,:)); diff(j(2,:))]./Ts];
jdd = [[0; 0] [diff(jd(1,:)); diff(jd(2,:))]./Ts];

end

