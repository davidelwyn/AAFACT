function [TM] = TranMat(coords_final_unit,Temp_Coordinates_Unit)

A = [0, 0, 0; Temp_Coordinates_Unit(2,:); Temp_Coordinates_Unit(4,:); Temp_Coordinates_Unit(6,:)];
B = [coords_final_unit(1,:); coords_final_unit(2,:); coords_final_unit(4,:); coords_final_unit(6,:)];

B_new = [B(2:4, 1:3) B(1,:)'; 0 0 0 1];

% Rotation and scaling components
R = A(2:4, 1:3) / B(2:4, 1:3);

% Translation components
T = A(1, 1:3)' - R * B(1, 1:3)';

% Transformation matrix
TM = eye(4);
TM(1:3, 1:3) = R;
TM(1:3, 4) = T;

A_new = TM*B_new; % Check TM

