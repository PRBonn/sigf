% Creates a 3x3 homogeneous similarity matrix from a rotation matrix,
% 2d translation vector and a scale factor
% Input:    R  3*3 rotation matrix
%           t 2d translation vector
%           lambda scale factor    
%
% Output:   S 3x3 homogeneous similarity matrix

function S = similarity_matrix_2d(R, t, lambda)

S = [lambda*R(1:2, 1:2), t;
     0, 0, 1];

end