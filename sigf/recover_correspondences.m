function M = recover_correspondences(P1, P2, T, params)

inlier_type = params.inlier_type;
thresh = params.thresh;
   
switch(inlier_type)
    case 'nn'
        M = compute_inliers_nn(P1, P2, T,thresh);
    case 'greedy'
        M = compute_inliers_greedy(P1, P2, T,thresh);
    case 'hungarian'
        M = compute_inliers_hungarian(P1, P2, T,thresh);
end

end