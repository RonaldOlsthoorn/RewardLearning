function [j, jd] = map_ref2(r_tool, reference_par, par)

j = zeros(2, length(r_tool(1,:)));
j(:,1) = [reference_par.start_joint(1); reference_par.start_joint(2)];

for i=2:length(r_tool(1,:)),
    
    j(:,i) = ik.ik_jac(j(:,i-1), r_tool(:,i), par);
end

jd = [[0; 0] [diff(j(1,:)); diff(j(2,:))]./reference_par.Ts];

end

