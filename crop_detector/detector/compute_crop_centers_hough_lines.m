% This function computes the crop centers given the vegetation mask using the
% centroid .
function centers = compute_crop_centers_hough_lines(M, params)

% read params
hough_params = params.hough_params;
min_object_size = params.min_object_size;
max_object_size = params.max_object_size;
avg_crop_size =   params.crop_size;
avg_crop_diameter = params.crop_diameter;

% compute hough lines from the entire image
[theta, rho] = compute_crop_rows_hough(M, hough_params);
if(isfield(params,'debug') && params.debug)
    fl = figure;
    imshow(M);
    draw_lines_parametric(fl,M, theta, rho);
    title('Hough lines detection')
end

% manage some figure handles 
if(isfield(params,'debug') && params.debug)
    frm = figure;
end
if(isfield(params,'manual_mode') && params.manual_mode)
    fitrc = figure;
end

% compute centers along each line
M_rows = zeros(size(M));
centers = [];
for i = 1 : length(theta)
    
    % compute a strip around the crop row
    M_row_mask = compute_crop_row_mask(M, theta(i), rho(i));
    M_row = imbinarize(M.*M_row_mask);
    M_rows = M_rows | M_row_mask;
    
    % set size parameters for finding crop centers
    if(isfield(params,'manual_mode') && params.manual_mode)
        crop_params.manual_mode = params.manual_mode;     
    else
        stats = compute_crop_size_stats(M_row);
        size_factor = 1.0; %(use for coarse adjustment)
        crop_params.min_object_size = floor(stats.median_size/4);
        crop_params.max_object_size = floor(stats.median_size*20);
        crop_params.crop_size = stats.median_size*size_factor;
        crop_params.crop_diameter = stats.crop_diameter;
    end
    
    % Visualize
    if(isfield(params,'debug') && params.debug)
        figure(frm); clf;
        imshow(M_row);
        hold on;
        plot_ellipse_regionprops(stats.crop_region)
        title('Row mask');
        waitforbuttonpress;
    end
    
    % compute centers
    if(isfield(params,'manual_mode') && params.manual_mode)
        ok = 0;
        while(~ok)
            centers_row = compute_crop_centers(M_row, crop_params);
            figure(fitrc);clf;
            imshow(M_row)
            hold on;
            plot(centers_row(:,1),centers_row(:,2), 'xr','LineWidth', 2);            
            title('Detected crop points.')
            ukey = input('Are the crop points ok?','s');
            if(isempty(ukey))
                ok = 1;
            end
        end
    else
        centers_row = compute_crop_centers(M_row, crop_params);
    end
    % collect all the points
    centers = [centers; centers_row];
    
end

% manage regions around crop rows not detected by hough lines
M_remaining_mask = ~M_rows;
M_remaining = imbinarize(M.*M_remaining_mask);
centers_remaining = compute_crop_centers(M_remaining, params);
centers = [centers; centers_remaining];

end