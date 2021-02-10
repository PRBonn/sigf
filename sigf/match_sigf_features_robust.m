% This fuction computes indices of matching pairs given the sigf 
% descriptors for the two point sets .
% Input:
%       D1: descriptor for point set 1
%       D2: descriptor for point set 2
%       params :
%              matching_params
%              ransac_params
%              recovery_params
% Output:
%       match_pairs : list of matching point indices (Nx2)

function match_pairs = match_sigf_features_robust(P1,P2,D1,D2,params)

% Read all parameters
% To Do: Add default parameters
match_params    = params.match_params;
ransac_params   = params.ransac_params;
recovery_params = params.recovery_params;

% match descriptors in a one vs all fashion
init_pairs = match_sigf_features(D1,D2,match_params);

% estimate similarity transformation in a ransac step
[tx_est, ty_est, theta_est, s_est, M_ransac] = estimate_similarity_transformation_from_matches_ransac(P1, P2, init_pairs', ransac_params);

% perform recovery step
if(recovery_params.do)
    R_est = rotation_matrix_2d(theta_est);
    T_est = similarity_matrix_2d(R_est,[tx_est, ty_est]', s_est);
    M_recover = recover_correspondences(P1, P2, T_est,recovery_params);
    match_pairs = M_recover';
else
    match_pairs = M_ransac';
end


end