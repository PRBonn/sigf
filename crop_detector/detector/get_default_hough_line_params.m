% Returns the default parameters for estimating hough lines.
function hough_params = get_default_hough_line_params()
hough_params.max_num_lines = 30;    %(Default: 30)
hough_params.split_image = false;   %(Default: false)
hough_params.num_image_splits = 2;  %(Default: 2)
hough_params.dilation = false;      %(Default: false)
hough_params.dilation_size = 5;     %(Default: 5)
params.erosion = false;             %(Default: false)
params.erosion_size = 5;            %(Default: 5)
hough_params.peak_thresh = 0.5;     %(Default: 0.5)
hough_params.theta_min = -90;       %(Default: -90)
hough_params.theta_max = 89;        %(Default: -89)
hough_params.debug = false;         %(Default: false)
end