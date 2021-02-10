% filter outlier lines
function [theta_inliers, rho_inliers] = filter_outlier_hough_lines(theta,rho)
% Remove lines which are not close to the general direction of the rows 
% get median theta for lines 
theta_thresh = deg2rad(20);
theta_median = median(theta);

% compute how far they are from median
theta_diff = abs(theta -theta_median);
idx1 =  (theta_diff < theta_thresh);

theta_inliers = theta(idx1);
rho_inliers = rho(idx1);

end
