function dist_avg =  compute_avg_inter_crop_distance(M, params)

% compute crop rows using hough lines
hough_params = get_default_hough_line_params();
hough_params.split_image = true;   %(Default: false)
hough_params.num_image_splits = 5; %(Default: 2)
hough_params.peak_thresh = 0.2;    %(Default: 0.5)

[theta_all, rho_all] = compute_crop_rows_hough(M, hough_params);

% visualize the crop points
if(isfield(params,'debug') && params.debug)
    fm = figure;
    figure(fm);
    imshow(M);
    draw_lines_parametric(fm, M, theta_all, rho_all);
end


% compute inter crop distance for each row
dist_all = zeros(1,length(theta_all));
for l = 1 : length(theta_all)
    % get mask for current row
    M_row_mask = compute_crop_row_mask(M, theta_all(l), rho_all(l));
    M_row = imbinarize(M.*M_row_mask);
    
    % find inter crop distance for current row
    dist = compute_inter_crop_distance(M_row, params);
    if(dist > 0)
        dist_all(l) = dist; 
    end    
end

% draw the histogram of computed inter-crop distances for all rows
if(isfield(params,'debug') && params.debug)
    fdh = figure;
    hist(dist_all)
end

% take the median of intercrop distances from all rows
dist_avg = median(dist_all);

end
