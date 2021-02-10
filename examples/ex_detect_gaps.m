% Example script to demonstrate detection of gaps in the field image.
clc; clear;
close all;

addpath(genpath('../crop_detector'))
addpath('../utils')

%% Load data
% load images
I = imread('../data/orig/DJI_1002.JPG');

% load the field mask 
F = imbinarize(imread('../data/field_masks/DJI_1002.png'));

%% Detection
% compute vegetation mask
M = extract_vegetation_mask(I);

% Apply the field masks
M = imbinarize(F.*M);

% compute gap points
detection_params   = generate_gap_detection_params(M);
P = compute_gap_centers(M, detection_params)';

% Visualize the gap points
figure(1)
imshow(I);
hold on;
plot(P(1,:), P(2,:),'.b','MarkerSize',10);
title('Gap points')
