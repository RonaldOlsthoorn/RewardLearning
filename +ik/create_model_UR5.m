function [ model_UR5 ] = create_model_UR5()

L(1) = Link('revolute', 'd', 0.089159, 'a', 0, 'alpha', pi/2,...
    'offset', 0);

L(2) = Link('revolute', 'd', 0, 'a', -0.42500, 'alpha', 0,...
    'offset', 0);

L(3) = Link('revolute', 'd', 0, 'a', -0.39225, 'alpha', 0,...
    'offset', 0);

L(4) = Link('revolute', 'd', 0.10915, 'a', 0, 'alpha', pi/2,...
    'offset', 0);

L(5) = Link('revolute', 'd', 0.09465, 'a', 0, 'alpha', -pi/2,...
    'offset', 0);

L(6) = Link('revolute', 'd', 0.0823, 'a', 0, 'alpha', 0,...
    'offset', 0);

model_UR5=SerialLink(L, 'name', 'UR5');
model_UR5.tool=transl(0,0,0);
model_UR5.ikineType = 'ur5';
model_UR5.model3d = 'UR/UR5_arc';

end

