% Example script to demonstrate matching of two field images using
% precomputed gap points
clc; clear;
close all;

addpath('../sigf')
addpath('../utils')

%% Load data
% load images 
I1 = imread('../data/orig/DJI_1002.JPG');
I2 = imread('../data/orig/DJI_2003.JPG');

% load gap points
gaps1 = load('../data/gaps/DJI_1002.mat');
gaps2 = load('../data/gaps/DJI_2003.mat');
P1 = gaps1.P;
P2 = gaps2.P;
N1 = size(P1,2);
N2 = size(P2,2);

% Visualize the gap points
figure(1)
imshow(I1);
hold on;
plot(P1(1,:), P1(2,:),'.b','MarkerSize',10);
title('Point set 1')

figure(2)
imshow(I2);
hold on;
plot(P2(1,:), P2(2,:),'.r','MarkerSize',10)
title('Point set 2')

%% Parameter Settings

% sigf descriptor related
desc_params.k = 5; % # of nearest neighbours
desc_params.order = 'ori'; % dist/ori
desc_params.ref = 'far'; % far/stable

% matching related
match_params.ratio = 0.6; % acceptance ratio
match_params.type = 'norm'; % norm/diff/weighted/rotated

% ransac parmeters
ransac_params.thresh = 30; %distance in pixels to be considered as the same point
ransac_params.iter = 100; % maximum number of iterations
ransac_params.debug = false; % display debug messages

% recovery params
recovery_params.do = true; % to perform recovery step or not
recovery_params.thresh = 30; %distance in pixels to be considered as the same point
recovery_params.inlier_type = 'hungarian'; % use nn (nearest neighbour)/ greedy /hungarian

match_params_all.match_params = match_params;
match_params_all.ransac_params = ransac_params;
match_params_all.recovery_params = recovery_params;

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
