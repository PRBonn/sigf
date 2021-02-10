% This function implements a direct solution for the least squares solution
% for estimating the parameters of  a 2D similarity transformation between
% corresponding point sets. A minimum of two point correspondences are
% required.
% Input: P1: 2D Points in set 1 
%        P2: 2D Points in set 2
%        M: 2xN matrix with corresponding indices of points in P1 and P2
% Output: tx,ty: estimate of 2D translation parameters  
%         theta: estimate of rotation parameter 
%         s: estimate of scale parameter


function [tx, ty, theta, s] = estimate_similarity_transformation_with_known_correspondences(P1, P2, M)

% initialze 
tx  = []; ty = []; theta = []; s = [];
if size(M,2) < 2
    fprintf('Need at least 2 points to compute similarity transformation!')
    return
end

% num_matches
k = size(M,2);
p1 = zeros(2,k);
p2 = zeros(2,k);

for i = 1: k
    p1(:,i) = P1(:,M(1,i));
    p2(:,i) = P2(:,M(2,i));
end

% compute mu_x1, mu_y1, mu_x2, mu_y2 
mu_x1 = sum(p1(1,:));
mu_y1 = sum(p1(2,:));
mu_x2 = sum(p2(1,:));
mu_y2 = sum(p2(2,:));

% compute l_1p2, l_1m2
l_1p2 = sum(sum(p1(1,:).*p2(1,:) + p1(2,:).*p2(2,:)));
l_1m2 = sum(sum(p1(1,:).*p2(2,:) - p1(2,:).*p2(1,:)));

% compute l_11
l_11 = sum( p1(1,:).^2 + p1(2,:).^2 );

% compute det_r
det_r = k*l_11 - mu_x1^2 - mu_y1^2;

% compute M_P1, M_P2 
M_P1 = [l_11, 0, -mu_x1, mu_y1;
        0, l_11, -mu_y1, -mu_x1;
        -mu_x1, -mu_y1, k, 0;
        mu_y1, -mu_x1, 0, k];
M_P2 = [mu_x2, mu_y2, l_1p2, l_1m2]';

% compute registration parameters
r = 1/det_r*M_P1*M_P2;

% set output params
tx = r(1);
ty = r(2);
theta =  atan2(r(4),r(3));
s = r(3)/cos(theta);

end