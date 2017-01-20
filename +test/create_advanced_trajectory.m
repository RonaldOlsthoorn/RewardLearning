function [t, x_tool] = create_advanced_trajectory( reference_par )

t = 0:reference_par.Ts:(reference_par.duration-reference_par.Ts);
x_tool = zeros(2, length(t));

for i = 1:2
    t0 = t(1:reference_par.viapoint_t);
    
    a = (reference_par.start_tool(i) - reference_par.viapoint(i))/...
        (0 - reference_par.viapoint_t*reference_par.Ts)^2;
    
    p = reference_par.viapoint_t*reference_par.Ts;
    c = reference_par.viapoint(i);
    
    Y0 = f_quad(a,p,c,t0);
    
    x1 = reference_par.viapoint_t*reference_par.Ts;
    y1 = reference_par.viapoint(i);
    x2 = reference_par.viaplane_t(1)*reference_par.Ts;
    y2 = reference_par.plane_level(i);
    
    k1 = (((x2-x1)/2))^2;
    k2 = (((x1-x2)/2))^2;
    
    c1 = ((x2-x1)/2);
    c2 = (x1-x2)/2;
    
    a1 = (y2-y1)/(k1-((c1/c2)*k2));
    a2 = a1*(c1/c2);
    
    t_transistion = floor(reference_par.viapoint_t+(reference_par.viaplane_t(1)-reference_par.viapoint_t)/2);
    
    t1 = t((reference_par.viapoint_t+1):t_transistion);
    t2 = t((t_transistion+1):reference_par.viaplane_t(1));
    
    Y1 = f_quad(a1, x1, y1, t1);
    Y2 = f_quad(a2, x2, y2, t2);
    Y3 = reference_par.plane_level(i).*ones(1, length(t)-length([Y0 Y1 Y2]));
    
    x_tool(i,:) = [Y0 Y1 Y2 Y3];
end

end

function [y] = f_quad(a,p,c,x)

y = a*(x-p).^2+c;
end

