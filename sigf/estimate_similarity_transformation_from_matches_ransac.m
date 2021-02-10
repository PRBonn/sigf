% This function determines the inlier matching pairs and estimate the registration
% parameters in an iterative manner. (RANSAC)
% Input :
%        P1 : point set 1
%        P2 : point set 2
%        params:
%           thresh: matching threshold distance
%           iter: number of iterations
%           inlier_type: use nearest neighbours/hungarian method
% Output :
%       tx_best,ty_best
%       theta_best
%       s_best
%       Inliers


function [tx_best, ty_best, theta_best, s_best, M_best] = estimate_similarity_transformation_from_matches_ransac(P1, P2, M, params)

% initialize as empty
tx_best = []; ty_best= []; theta_best = [];  s_best = []; M_best = [];

% read in parameters
thresh_dist = params.thresh;
iter = params.iter;

% add path to util functions
addpath('../utils');
numM = size(M,2);

% initialize
l = 2;
numInliersBest = 0;
bestError = Inf;
M_inliers = [];

% For some number of iterations
for i = 1 : iter
    
    % Choose two matches randomly and compute a new transformation
    ok = false;
    while(~ok)
        r = randperm(numM);
        M_rand = M(:,r(1:l));
        if(M_rand(2,1) ~= M_rand(2,2))
             ok = true;
        end
    end
    % estimate model parameters using minimal number of matches (l=2)
    [tx, ty, theta, s] = estimate_similarity_transformation_with_known_correspondences(P1, P2, M_rand);
    R = rotation_matrix_2d(theta);
    T = similarity_matrix_2d(R,[tx, ty]', s);
    
    [error, M_inliers]= compute_inlier_matches(P1,P2,M,T,thresh_dist);
    numInliers = size(M_inliers,2);
    
    % update number of inliers and model if better model is found
    %if( numInliers > numInliersBest)
     if( error < bestError)
        bestError = error;
        numInliersBest = numInliers;
        tx_best = tx;
        ty_best = ty;
        theta_best = theta;
        M_best = M_inliers;
        s_best = s;
    end
    
    % Print status
    if isfield(params,'debug') && params.debug
        fprintf('[Ransac:] Iteration # = %d , # of inliers = %d \n',i, numInliers);
    end
end

% Compute least square solution using all inliers
%[tx_best, ty_best, theta_best, s_best] = estimate_similarity_transformation_with_known_correspondences(P1, P2, M_inliers);

end

