function centers = compute_crop_centers_hough(M, params)
% read params
hough_params = params.hough_params;
crop_params = params.crop_params;

MIN_CROP_DIST = crop_params.inter_crop_dist * crop_params.crop_acpt_ratio; 

% compute crop rows using hough transform
[theta, rho] = compute_crop_rows_hough(M, hough_params);
num_rows = length(theta);

% visualize the computed hough lines and the crop points
if(isfield(params,'debug') &&  params.debug)
    fl = figure;
    imshow(M);
    draw_lines_parametric(fl,M, theta, rho);
    fp = figure;
end

% compute histogram of crop pixels distribution along each crop row
points = []; hist = [];
centers = [];

for i = 1 : num_rows
    
    [points{i}, hist{i}] = compute_crop_row_histogram(M,theta(i),rho(i));
    pts = points{i};
    
    % smooth the histogram
    hist{i} = smooth(hist{i});
    
    %find peaks along crop rows
    if (~isempty(hist{i}))
        
        % find peaks (corresponding to the center of the crops)
        [pks,loc] = findpeaks(hist{i}, 'MinPeakDistance', MIN_CROP_DIST);
        
        centers = [centers; pts(loc,1),pts(loc,2)];
        
        % plot results
        if(isfield(params,'debug') &&  params.debug)
            
            figure(fl);
            hold on;
            plot(pts(loc,1),pts(loc,2),'rx','Linewidth',2)
            
            figure(fp);
            findpeaks(hist{i}, 'MinPeakDistance', MIN_CROP_DIST,  'Annotate', 'extents');
        end
    end
    
end

end



