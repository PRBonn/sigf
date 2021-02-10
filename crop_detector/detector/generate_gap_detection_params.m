%GET_GAP_DETECTION_PARAMS generates detection parameters for detecting gaps
% by computing statistics from the vegetation mask.
function [ detection_params] = generate_gap_detection_params( M )

% hough line params
hough_params = get_default_hough_line_params();
hough_params.max_num_lines = 30;
hough_params.split_image = true;   %(Default: false)
hough_params.num_image_splits = 6; %(Default: 2)
hough_params.peak_thresh = 0.4;    %(Default: 0.5)
hough_params.debug = false;        %(Default: false)

% compute some stats from the image
stats = compute_crop_size_stats(M);
detection_params.min_object_size = floor(stats.median_size/6);
detection_params.max_object_size = floor(stats.median_size*20);
detection_params.crop_size = stats.median_size;
detection_params.crop_diameter = stats.crop_diameter;
detection_params.use_row_inter_crop_distance = false;

% crop parameters
crop_params.avg_inter_crop_dist = compute_avg_inter_crop_distance(M,detection_params); %(in pixels)
crop_params.crop_radius = floor(detection_params.crop_diameter/2); %(in pixels)

% gap params
gap_params.avg_gap_width = 2*(crop_params.avg_inter_crop_dist - crop_params.crop_radius);
gap_params.gap_acpt_ratio = 0.7;
gap_params.gap_type = 'mid'; % mid/triplet/full

% set params for computing gap centers
detection_params.hough_params = hough_params;
detection_params.crop_params = crop_params;
detection_params.gap_params = gap_params;
detection_params.debug = false;

end

