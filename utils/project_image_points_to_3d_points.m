% Project image points into 3D points 
% Assumption: we assume that all the 3D points lie on a plane
% Desc: This function computes the ray for each image point, finds the
% intersection with the plane and returns the 3D point coordinates in the
% world frame.
% Reference : 
%
% Input : x image points (2D homogeneous coordinates)
%         M Motion matrix of the camera in the world frame
%         K Camera calibration matrix
%         A Equation of the plane in homogeneous coordinates
% Output : X 3D points (3D homogeneous coordinates)

function X =  project_image_points_to_3d_points(x, M, K, A)
%Skew matrix for a vector
skew = @(x) [0, -x(3), x(2); x(3), 0, -x(1); -x(2), x(1), 0];

num_points = size(x,2);
R = M(1:3,1:3);
t = M(1:3,4);
M_A = [R, zeros(3,1); 
      -t'*R 1];

X = [];  
for i = 1:num_points
    x1 = x(:,i);
    x1_r = inv(K)*x1;
    L = [x1_r ; zeros(3,1)];
    Lh = L(1:3); 
    L0 = L(4:6);
    
    Gamma_T = [skew(L0),  Lh;
              -Lh' 0];
    X_ = M*Gamma_T*inv(M_A)*A;
    X = [X, X_];
end

end