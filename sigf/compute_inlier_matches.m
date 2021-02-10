% This function computes the residuals and a list of inliers for the given 
% matches M under the transformation T. 
function [residual, inliers] = compute_inlier_matches(P, Q, M, T, thresh_dist)
% get points corresponding to the matches
nM = size(M,2);
Pm = P(:,M(1,:));
Qm = Q(:,M(2,:));

% compute points after transformation
Qm_hat = T*[Pm ; ones(1,nM)];
Qm_hat = Qm_hat(1:2,:);

% compute error
err = sqrt(sum((Qm_hat - Qm).^2));

inlier_idx = (err < thresh_dist);
inliers = M(:,inlier_idx);    

% compute residual
err(~inlier_idx) = thresh_dist;
residual = sum(err);

end