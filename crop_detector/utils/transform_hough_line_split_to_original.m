function [theta_hat, rho_hat] = transform_hough_line_split_to_original(I_size, split_num, num_splits, theta, rho)

% read image size 
H = I_size(1);
W = I_size(2);

% get distance to new origin
O = [1,1];
Op = [1, floor((split_num-1)*(W/num_splits)) + 1];
d = norm(O-Op);

% compute the transformed parameters
theta_hat = theta ;
rho_hat = rho + d*cos(theta);

end