% This function predicts the gap centers given the vegetation mask by using
% the detected points.
function gap_centers = predict_gap_centers(M, params)

% read parameters
hough_params = params.hough_params;
crop_params = params.crop_params;

% other params
inter_crop_dist = crop_params.avg_inter_crop_dist;
min_object_size = params.min_object_size;

% preprocessing
M = bwareaopen(M,min_object_size);

% fit lines through the crop rows
[theta, rho] = compute_crop_rows_hough(M, hough_params);
num_lines = length(theta);

if(isfield(params,'debug') && params.debug)
    fll = figure;
    figure(fll)
    hold on;
    imshow(M);
    draw_lines_parametric(fll,M, theta, rho);
end


% compute gap centers for each line
Pg = [];
for l = 1 : num_lines
    % set rho and theta for current row
    theta_r = theta(l); rho_r = rho(l);
    
    % extract the row mask
    M_row_mask = compute_crop_row_mask(M, theta_r, rho_r);
    M_row = imbinarize(M.*M_row_mask);
    
    if(isfield(params,'debug') && params.debug)
        frm = figure;
        figure(frm)
        hold on;
        imshow(M_row);
        draw_lines_parametric(fll,M_row, theta_r, rho_r);
    end
    
    % compute crop points along this row
    cparams.hough_params = get_default_hough_line_params();
    cparams.hough_params.max_num_lines = 1;
    cparams.crop_size = params.crop_size;
    cparams.crop_diameter = params.crop_diameter;
    cparams.min_object_size = params.min_object_size;
    cparams.max_object_size = params.max_object_size;
    P = compute_crop_centers(M_row,cparams);
    
    % visualize the crop points
    if(isfield(params,'debug') && params.debug)
        fcc = figure;
        figure(fcc);
        imshow(M_row);
        hold on;
        plot(P(:,1),P(:,2), 'xr','LineWidth', 2);
        draw_lines_parametric(fcc,M_row, theta_r, rho_r);
    end
    
    % compute expect crop point locations
    [~,sidx] = sort(P(:,2));
    Ps = P(sidx,:);
    Pe = zeros(size(Ps));
    Pe(1,:) = Ps(1,:);
    for i = 2 : length(Ps)
        theta_l = pi/2 - theta_r;
        Pe(i,1) = Ps(i-1,1) + inter_crop_dist*cos(theta_l);
        Pe(i,2) = Ps(i-1,2) + inter_crop_dist*sin(theta_l);
    end
    
    if(isfield(params,'debug') && params.debug)
        figure(fcc);
        plot(Pe(:,1),Pe(:,2), 'xg','LineWidth', 2);
    end
    
    %collect gaps if no detected points exists close to expected point
    for i = 1 : length(Pe)
        P_ = Pe(i,:);
        P_nearest = get_nearest_point(P_,Ps);
        dist_nearest = norm(P_ - P_nearest);
        if (dist_nearest > 1.5*params.crop_diameter)
            Pg = [Pg; P_];
        end
    end
    
    if(isfield(params,'debug') && params.debug)
        figure(fcc);
        if(~isempty(Pg))
            plot(Pg(:,1),Pg(:,2), 'xy','LineWidth', 2);
        end
    end
    
end

gap_centers = Pg;

end


function Pc = get_nearest_point(p,P)

%compute Euclidean distances
distances = sqrt(sum(bsxfun(@minus, P, p).^2,2));

%find the point corressponding to th esmallest distance
Pc = P(distances==min(distances),:);

end