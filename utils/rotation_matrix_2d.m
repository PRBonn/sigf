% Creates a 3x3 homogeneous rotation matrix from an angle
% Input: phi rotation angle (rad)
% Output: R 3x3 homogeneous rotation matrix
function R = rotation_matrix_2d(phi)

R = [cos(phi), -sin(phi), 0;
     sin(phi), cos(phi), 0;
     0, 0, 1];

end