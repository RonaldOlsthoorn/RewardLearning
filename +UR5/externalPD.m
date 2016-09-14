function [ v_feed ] = externalPD(r, rd, p, v)

Kp = 3;
Kd = 0.0375;

v_feed = Kp*(r - p)+ Kd*(rd - v);

end