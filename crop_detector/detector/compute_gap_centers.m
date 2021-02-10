% This function computes the gap centers given the vegetation mask.
function gap_centers = compute_gap_centers(M, params)
% read the parameters
hough_params = params.hough_params;
crop_params = params.crop_params;
gap_params = params.gap_params;

% set gap type
gap_type = gap_params.gap_type;

% set parameters used
min_object_size = params.min_object_size;
max_object_size = params.max_object_size;
avg_inter_crop_dist = crop_params.avg_inter_crop_dist;
avg_gap_width = gap_params.avg_gap_width;
gap_acpt_ratio = gap_params.gap_acpt_ratio;

% Preprocessing
% reject the really small objects
if(isfield(params,'debug') && params.debug)
    figure(100); hold on;
    imshow(M)
    title('Before applying size filter')
end

M = bwareaopen(M,min_object_size);

if(isfield(params,'debug') && params.debug)
    figure(101); hold on;
    imshow(M)
    title('After applying size filter')
end

% fit lines through the crop rows
[theta, rho] = compute_crop_rows_hough(M, hough_params);
num_lines = length(theta);

if(isfield(params,'debug') && params.debug)
    fll = figure;
    figure(fll)
    hold on;
    imshow(M);
    draw_lines_parametric(fll,M, theta, rho);
    fl = figure();
    figure(fl);
    hold on;
    imshow(M)
    fp = figure();
end

% compute crop pixels perpendicular to this direction
gap_centers = [];
for i = 1 : num_lines
    
    % extract the row mask
    M_row_mask = compute_crop_row_mask(M, theta(i), rho(i));
    M_row = imbinarize(M.*M_row_mask);
    
    % compute the intercrop distance fo the row
    % set default params
    cparams.crop_size = params.crop_size;
    cparams.crop_diameter = params.crop_diameter;
    cparams.min_object_size = params.min_object_size;
    cparams.max_object_size = params.max_object_size*20;
    cparams.manual_mode = false;
    
    if(isfield(params,'use_row_inter_crop_dist') && params.use_row_inter_crop_dist)
        inter_crop_dist = compute_inter_crop_distance(M_row, cparams);
        if (((inter_crop_dist - avg_inter_crop_dist)/avg_inter_crop_dist) > 0.5 || inter_crop_dist < 0 )
            inter_crop_dist = avg_inter_crop_dist;
        end
    else
        inter_crop_dist = avg_inter_crop_dist;
    end
    
    if(isfield(params,'debug') && params.debug)
        % print inter crop distance computed for the current row
        fprintf('Inter-crop distance = %d \n',inter_crop_dist);
        
        % visulize current crop row
        draw_lines_parametric(fl,M, theta(i), rho(i));
    end
    
    % compute gap width
    gap_width = 2*(inter_crop_dist - crop_params.crop_radius);
    
    % compute crop pixels histogram along the row
    [pts, hist]  = compute_crop_row_histogram(M,theta(i),rho(i));
    
    % smoothen the histogram
    hist = smooth(hist);
    
    % find out centers of the gaps
    gap_params_line.gap_width = gap_width;
    gap_params_line.gap_acpt_ratio = gap_acpt_ratio;
    crop_params_line.inter_crop_dist = inter_crop_dist;
    crop_params_line.crop_radius = crop_params.crop_radius;
    
    if strcmp(gap_type,'triplet')
        gc_line = locate_gap_centers_triplet(pts, hist, gap_params_line, crop_params_line);
    elseif strcmp(gap_type,'full')
        gc_line = locate_gap_centers_full(pts, hist, gap_params_line, crop_params_line);
    else %(default: mid)
        gc_line = locate_gap_centers_mid(pts, hist, gap_params_line);
    end
    
    if(isfield(params,'debug') && params.debug)
        % plot results
        figure(fl);
        hold on;
        plot(gc_line(:,1),gc_line(:,2),'gx','Linewidth',2)
        
        % plot crop profile along the row
        figure(fp);clf;
        findpeaks(-hist,'MinPeakWidth', gap_width*gap_acpt_ratio, 'Annotate', 'extents');
    end
    
    % Append to previously computed gaps
    gap_centers = [gap_centers; gc_line];
end


end


function gc = locate_gap_centers_mid(pts, hist, gap_params)
% set parameters
gap_width = gap_params.gap_width;
gap_acpt_ratio = gap_params.gap_acpt_ratio;

% gap centers
gc = [];
if (~isempty(hist))
    [~, loc, wpks, ~] = findpeaks(-hist,'MinPeakWidth', gap_width*gap_acpt_ratio);
    
    % set center of the valleys as the location of the gaps
    loc_gaps = round((loc + wpks/2));
    
    % collect all the gap locations
    gc = [gc; pts(loc_gaps,1),pts(loc_gaps,2)];
    
end

end

function gc = locate_gap_centers_full(pts, hist, gap_params, crop_params)
% set parameters
gap_width = gap_params.gap_width;
gap_acpt_ratio = gap_params.gap_acpt_ratio;
inter_crop_dist = crop_params.inter_crop_dist;
crop_radius = crop_params.crop_radius;

% gap centers
gc = [];
if (~isempty(hist))
    % find peaks in the (negative )histogram
    [~, loc, wpks, ~] = findpeaks(-hist,'MinPeakWidth', gap_width*gap_acpt_ratio);
    
    % find centers of each of the missing crops in the gap
    for i = 1 : length(loc)
        num_gaps = round((wpks(i)+2*crop_radius)/inter_crop_dist)-1;
        loc_gaps = loc(i) + linspace(0,wpks(i),num_gaps+2);
        loc_gaps = round(loc_gaps(2:end-1));
        
        % collect all the gap locations
        gc = [gc; pts(loc_gaps,1),pts(loc_gaps,2)];
    end
end

end

function gc = locate_gap_centers_triplet(pts, hist, gap_params, crop_params)

% set parameters
gap_width = gap_params.gap_width;
gap_acpt_ratio = gap_params.gap_acpt_ratio;

% gap centers
gc = [];
if (~isempty(hist))
    [~, loc, wpks, ~] = findpeaks(-hist,'MinPeakWidth', gap_width*gap_acpt_ratio);
    
    if(~isempty(loc))
        % set center of the valleys as the location of the gaps and the
        % cornets as the egde points 
        loc_gaps = round((loc + wpks/2));
        loc_gap_edges1 = round(loc);
        loc_gap_edges2 = round(loc + wpks);
        
        % remove redundant points
        redundant_point_thresh = crop_params.crop_radius*2;
        loc_gap_edges = filter_redundant_gap_edges(loc_gap_edges1, loc_gap_edges2, redundant_point_thresh);
        
        % collect all the gap locations and the edges
        gc = [gc; pts(loc_gaps,1),pts(loc_gaps,2)];
        gc = [gc; pts(loc_gap_edges,1),pts(loc_gap_edges,2)];
    end
end

end

function loc = filter_redundant_gap_edges(loc1, loc2, thresh)

% compute diffences in edge point positions
diff = [Inf; abs(loc1(2:end) - loc2(1:end-1))];

% index of repeated points
rep_l1 = (diff < thresh);
rep_l2 = circshift(rep_l1,-1);

% collected non repeated points and take the average for repeated points
loc = [loc1(~rep_l1); round((loc1(rep_l1) +  loc2(rep_l2))/2); loc2(~rep_l2)];
loc = sort(loc);

end
