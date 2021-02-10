% Example script to demonstrate matching of two field images.
clc; clear;
close all;

addpath(genpath('../crop_detector'))
addpath('../sigf')
addpath('../utils')


%% Load data
% load images
I1 = imread('../data/orig/DJI_1002.JPG');
I2 = imread('../data/orig/DJI_2003.JPG');

% load the field mask 
F1 = imbinarize(imread('../data/field_masks/DJI_1002.png'));
F2 = imbinarize(imread('../data/field_masks/DJI_2003.png'));

%% Parameter Settings
% sigf descriptor related
desc_params.k = 5; % # of nearest neighbours
desc_params.order = 'ori'; % dist/ori
desc_params.ref = 'far'; % far/stable

% matching related
match_params.ratio = 0.7; % acceptance ratio
match_params.type = 'norm'; % norm/diff/weighted/rotated

% ransac parmeters
ransac_params.thresh = 30; %distance in pixels to be considered as the same point
ransac_params.iter = 1000; % maximum number of iterations
ransac_params.debug = false; % display debug messages

% recovery params
recovery_params.do = true; % to perform recovery step or not
recovery_params.thresh = 30; %distance in pixels to be considered as the same point
recovery_params.inlier_type = 'hungarian'; % use nn (nearest neighbour)/ greedy /hungarian

match_params_all.match_params = match_params;
match_params_all.ransac_params = ransac_params;
match_params_all.recovery_params = recovery_params;


%% Detection
% compute vegetation mask
M1 = extract_vegetation_mask(I1);
M2 = extract_vegetation_mask(I2);

% Apply the field masks
M1 = imbinarize(F1.*M1);
M2 = imbinarize(F2.*M2);   

% compute gap points
detection1_params   = generate_gap_detection_params(M1);
detection2_params   = generate_gap_detection_params(M2);
P1 = compute_gap_centers(M1, detection1_params)';
P2 = compute_gap_centers(M2, detection2_params)';

% Visualize the gap points
figure(1)
imshow(I1);
hold on;
plot(P1(1,:), P1(2,:),'.b','MarkerSize',10);
title('Point set 1')
pause(1)

figure(2)
imshow(I2);
hold on;
plot(P2(1,:), P2(2,:),'.r','MarkerSize',10)
title('Point set 2')
pause(1)

%% Matching
% compute the descriptors
D1 = sigf(P1, desc_params);
D2 = sigf(P2, desc_params);

% matching using descriptor only
matches = match_sigf_features(D1,D2, match_params);

% matching + ransac + recovery
matches_all = match_sigf_features_robust(P1, P2, D1,D2, match_params_all);

%% visualize results
figure(3);
showMatchedFeatures(I1,I2, P1(:, matches(:,1))', P2(:,matches(:,2))','montage');
title('SIGF Matches');

figure(4);
showMatchedFeatures(I1,I2, P1(:, matches_all(:,1))', P2(:,matches_all(:,2))','montage');
title('SIGF Matches + Ransac + Recovery');