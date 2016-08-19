function Y = ode4_ti(odefun, tspan, y0, varargin)

%Calls wrapper function. Convenient for imports.
Y = ode4_ti(odefun,tspan,y0,varargin{:});

end