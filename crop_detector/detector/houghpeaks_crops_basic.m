% This function is a custom implementation of the hough peaks which also 
% incorporates some prior knowledge.
function P = houghpeaks_crops_basic(H, max_num_lines, peak_thresh)
P_prior = houghpeaks(H);
theta_prior_ind = P_prior(2);
H_crops = H(:, theta_prior_ind);

P  = houghpeaks(H_crops, max_num_lines,'Threshold',peak_thresh);
P(:,2) =  theta_prior_ind;

end