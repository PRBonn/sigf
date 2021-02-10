% This function computes a list of inliers which fall within the matching
% radius.

function inliers = compute_inliers_nn(P, Q, T,thresh_dist)

% compute estimated point
nP = size(P,2);
nQ = size(Q,2);
Q_hat = T*[P; ones(1,nP)];
Q_hat = Q_hat(1:2,:);

% get closest neighbour (using knnsearch) 
idx = knnsearch(Q', Q_hat');
M = [1 : length(Q_hat); idx'];  

% compute error
diff = Q_hat - Q(:,idx);
dist = sqrt(sum(diff.^2));

% get indices of all points within the threshold distance
ind = (dist<=thresh_dist);

% get inliers
inliers = M(:,ind);

end