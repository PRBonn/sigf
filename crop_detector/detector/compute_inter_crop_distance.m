% function to compute inter crop distance from the vegetation mask for a
% crop row.
% Note: returns dist = -1 if it cannot compute the inter crop distance.
function dist = compute_inter_crop_distance(M_row, params)
%addpath('../external/ginputc/');

if(isfield(params,'manual_mode') && params.manual_mode)
    fmm = figure;
    figure(fmm);
    hold on;
    imshow(M_row);
    [x,y] = ginputc(2,'Color',[1,0,0]);
    dist = sqrt((x(1)-x(2))^2 + (y(1)-y(2))^2);
    
else
    % compute crop size parameters
    stats = compute_crop_size_stats(M_row);
    if(~isempty(stats))
        cparams.crop_size = 1.5*stats.median_size;
        cparams.crop_diameter = stats.crop_diameter;
        cparams.min_object_size = floor(stats.median_size/4);
        cparams.max_object_size = floor(stats.median_size*20);
        
    else % use pre-computed params
        cparams.crop_size = params.crop_size;
        cparams.crop_diameter = params.crop_diameter;
        cparams.min_object_size = params.min_object_size;
        cparams.max_object_size = params.max_object_size;
    end
    
    % compute crop centers
    P = compute_crop_centers(M_row, cparams);
    
    if(~isempty(P))
        % compute line through current row
        cparams.hough_params = get_default_hough_line_params();
        cparams.hough_params.max_num_lines = 1;
        [theta_r, rho_r] = compute_crop_rows_hough(M_row, cparams.hough_params);
        
        % visualize the crop points
        if(isfield(params,'debug') && params.debug)
            fcc = figure;
            figure(fcc);
            imshow(M_row);
            hold on;
            plot(P(:,1),P(:,2), 'xr','LineWidth', 2);
            draw_lines_parametric(fcc,M_row, theta_r, rho_r);
        end
        
        % find intercrop distance
        [~,sidx] = sort(P(:,2));
        Ps = P(sidx,:);
        crop_dists = zeros(1, length(Ps)-1);
        for i = 1 : length(crop_dists)
            crop_dists(i) = sqrt((Ps(i,1) - Ps(i+1,1))^2 + (Ps(i,2) - Ps(i+1,2))^2);
        end
        
        % draw the histogram of computed inter-crop distances
        if(isfield(params,'debug') && params.debug)
            fdh = figure;
            hist(crop_dists);
        end
        
        % find median of this distance
        dist = median(crop_dists);
        
        % visulalize expected crop locations using this distance
        if(isfield(params,'debug') && params.debug)
            Pe = zeros(size(Ps));
            Pe(1,:) = Ps(1,:);
            for i = 2 : length(Ps)
                theta = pi/2 - theta_r;
                Pe(i,1) = Ps(i-1,1) + dist*cos(theta);
                Pe(i,2) = Ps(i-1,2) + dist*sin(theta);
            end
            
            figure(fcc);
            plot(Pe(:,1),Pe(:,2), 'xg','LineWidth', 2);
        end
        
    else % could not compute inter-crop distance
        dist = -1;
    end
    
end


end