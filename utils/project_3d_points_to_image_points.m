% Project 3d points to image points given the projection matrix and image
% size
% Input: Projection matrix P (3x4)
%        3D points (homogeneous coordinates)
%        height, width of the image
% Output: x 2D image points (homogeneous coordinates)
%         X_ 3D points which lie with field of view of the camera (homogeneous coordinates)
%         ind : indices of all the points in the field of view 

function [x, X_, ind] = project_3d_points_to_image_points(P, X, height, width)
cx = width/2;
cy = height/2;
x = [];
X_ = [];
ind = [];
for i = 1:size(X,2) 
    x1 = P * X(:,i) ;
    x1 = x1/x1(end);
    
    % check if points lie within image boundaries 
    if x1(1) > 0 && x1(1) <= width && x1(2) > 0 && x1(2) <= height
        x = [x, x1];
        X_ = [X_, X(:,i)];
        ind = [ind, i];
    end

end

end