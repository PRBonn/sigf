% Test matching of two point sets using sigf descriptor.
% To Do: Add recovery step tests

clc; clear;
close all;
addpath('../utils')

% load dataset from field
dataset_path = '../../data/ex_simulated/cameras';
camera1_file = 'camera_x_7_y_7_z_5_sigma_0_detec_0.mat';
camera2_file = 'camera_x_7_y_7_z_7_sigma_0_detec_0.mat';
camera1 = load(strcat(dataset_path,'/',camera1_file));
camera2 = load(strcat(dataset_path,'/',camera2_file));

% Set parameters for sigf descriptor
params.k = 5; % # of nearest neighbours
params.order = 'ori'; % dist/ori
params.ref = 'far'; % far/stable

% set parameters for matching
match_params.ratio = 0.6; % acceptance ratio
match_params.type = 'norm'; % norm/diff/weighted/rotated
match_params.debug = true;

% ground truth data
P1_0 = camera1.camera.x;
ind1_0 = camera1.camera.ind;
P2_0 = camera2.camera.x;
ind2_0 = camera2.camera.ind;
M12_0 = get_correspondece_matrix_from_indices(ind1_0, ind2_0);
[tx0, ty0, theta0, s0] = estimate_similarity_transformation_with_known_correspondences(P1_0,P2_0,M12_0);
   
% test data
P1 = camera1.camera.x_noisy;
ind1 = camera1.camera.ind_noisy;
P2 = camera2.camera.x_noisy;
ind2 = camera2.camera.ind_noisy;
M12 = get_correspondece_matrix_from_indices(ind1, ind2);
N1 = size(P1,2);
N2 = size(P2,2);

% Visualize data
figure(1);
clf; hold on; grid on; axis equal; box on;
plot(P1_0(1,:), P1_0(2,:),'+b','MarkerSize',10)
plot(P1(1,:), P1(2,:),'.b','MarkerSize',10)
title('Point set 1')

figure(2);
clf; hold on; grid on; axis equal; box on;
plot(P2_0(1,:), P2_0(2,:),'+r','MarkerSize',10)
plot(P2(1,:), P2(2,:),'.r','MarkerSize',10)
title('Point set 2')

figure(3);
clf; hold on; grid on; axis equal; box on;
plot(P2_0(1,:), P2_0(2,:),'.r','MarkerSize',10)
hold on;
plot(P2_0(1,M12_0(2,:)), P2_0(2,M12_0(2,:)),'xb','MarkerSize',10)
xlabel('x-axis'); ylabel('y-axis');
axis([0 ceil(max(P2(1,:))) 0 ceil(max(P2(2,:)))]);
title('Ground truth data');

% compute the descriptors
D1 = sigf(P1, params);
D2 = sigf(P2, params);

% Match descriptors from the two point sets
index_pairs = match_sigf_features(D1,D2, match_params);

% Compare correct correspondences to ground truth
correct = evaluate_correspondence_estimate(index_pairs', M12);
fprintf('Number of correct correspondences estimated = %g/%g,[GT=%g] \n',correct,length(index_pairs),length(M12_0))

%% Estimate similarity transformation
ransac_params.thresh = 6; %distance in pixels to be considered as the same point
ransac_params.iter = 100; % maximum number of iterations
ransac_params.inlier_type = 'hungarian'; % use nn (nearest neighbour) or hungarian
ransac_params.debug = true; % display debug messages
[tx_est, ty_est, theta_est, s_est, M_est] = estimate_similarity_transformation_from_matches_ransac(P1, P2, index_pairs', ransac_params);

% Compare correct correspondences to ground truth
correct_ransac = evaluate_correspondence_estimate(M_est, M12);
fprintf('Number of correct correspondences estimated (RANSAC)= %g/%g,[GT=%g] \n', correct_ransac, length(M12_0))

% Visualize correspondences
% ground truth matches 
f_gt = figure;
show_matched_points(P1,P2,M12');
figure(f_gt);
hold on;
title('Ground truth correspondences');
xlabel(['# of ground truth matches =', num2str(length(M12_0))])

% estimated matches
fc = figure;
show_matched_points(P1,P2,index_pairs);
figure(fc);
hold on;
title('Estimated correspondences');
xlabel(['# of correct matches =', num2str(correct),'/',num2str(length(index_pairs)), ' GT =', num2str(length(M12_0))])

fc_ransac = figure; 
show_matched_points(P1,P2,M_est');
figure(fc_ransac);
hold on;
title('Estimated correspondences (After Ransac)');
xlabel(['# of correct matches =', num2str(correct_ransac),'/', num2str(length(M12_0))])




