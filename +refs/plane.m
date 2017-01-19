function [ plane ] = plane( reference_par )

plane.t = (reference.plane_t(1):reference.plane_t(2))*Ts;
n = length(plane.t);
d = length(reference_par.start);

switch reference_par.plane_dim
    case 'x'
        if d==2
            plane.tool = [reference_par.level*ones(1,n); nan(1,n)];
        elseif d==3
            plane.tool = [reference_par.level*ones(1,n); nan(1,n); nan(1,n)];
        end
    case 'y'
        if d==2
            plane.tool = [nan(1,n); reference_par.level*ones(1,n)];
        elseif d==3
            plane.tool = [nan(1,n); reference_par.level*ones(1,n); nan(1,n)];
        end
    case 'z'
        plane.tool = [nan(1,n); nan(1,n); reference_par.level*ones(1,n)];
    case 'xy'
        if d==2
            plane.tool = [reference_par.level(1)*ones(1,n); reference_par.level(2)*ones(1,n)];
        elseif d==3
            plane.tool = [reference_par.level(1)*ones(1,n); reference_par.level(2)*ones(1,n); nan(1,n)];
        end
end
end

