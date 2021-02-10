% This function computes the crop rows using the hough transformation.
% Input:    Image : vegetation mask
% Output:   theta,rho : parameters of the lines
% To Do:
% Use prior info to remove outliers etc
function [theta, rho] = compute_crop_rows_hough(I, params)

% set parameters
if(isfield(params,'split_image') && params.split_image)
    if(isfield(params,'num_image_splits'))
        num_image_splits = params.num_image_splits;
    else
        num_image_splits = 2;
    end
else
    num_image_splits = 1;
end

% max num of lines
if(isfield(params,'max_num_lines'))
    max_num_lines = params.max_num_lines;
else
    max_num_lines = 30;
end

% set peak threshold
if(isfield(params,'peak_thresh'))
    peak_thresh = params.peak_thresh;
else
    peak_thresh = 0.5;
end

% set peak threshold
if(isfield(params,'theta_min') && isfield(params,'theta_max'))
    theta_range = params.theta_min : params.theta_max;
else
    theta_range = -90:89;
end

if(isfield(params,'debug') && params.debug)
    fd_out = figure;
    fd_mult = figure;
end

I_orig = I;
theta = [];
rho = [];
ind_splits = get_image_split_indices(size(I),num_image_splits);

for i = 1 : num_image_splits
    
    I = I_orig(:, ind_splits(i,1) : ind_splits(i,2));
    
    % dilate the image
    if(isfield(params,'dilation') && params.dilation)
        if(isfield(params,'dilation_size'))
            SE = strel('disk', params.dilation_size);
        else
            SE = strel('disk', 5);
        end
        I = imdilate(I,SE);
    end
    
    % erode the image
    if(isfield(params,'erosion') && params.erosion)
        if(isfield(params,'dilation_size'))
            SE = strel('disk', params.erosion_size);
        else
            SE = strel('disk', 5);
        end
        I = imerode(I,SE);
    end
    
    
    % compute hough transform
    [H,T,R] = hough(I,'Theta', theta_range);
    
    % plot the hough transform
    if(isfield(params,'debug') && params.debug)
        fh = figure;
        hold on;
        imshow(H,[],'XData',T,'YData',R,...
            'InitialMagnification','fit');
        axis on, axis normal;
        xlabel('\theta'), ylabel('\rho')
    end
    
    % compute hough peaks
    P =  houghpeaks_crops_basic(H, max_num_lines,peak_thresh*max(H(:)));
    
    % plot the peaks
    if(isfield(params,'debug') && params.debug)
        x = T(P(:,2)); y = R(P(:,1));
        figure(fh);
        hold on;
        plot(x,y,'s','color','white');
        hold off
    end
    
    % plot lines corresponding to the peaks
    thetaP = deg2rad(T(P(:,2)));
    rhoP =  R(P(:,1));
    
    if(isfield(params,'debug') && params.debug)
        fl = figure;
        figure(fl);clf;
        imshow(I);
        draw_lines_parametric(fl,I, thetaP, rhoP);
        title('Before rejecting outlier lines')
    end
    
    % filter outlier lines
    [thetaP, rhoP] = filter_outlier_hough_lines(thetaP,rhoP);
    
%     if(isfield(params,'debug') && params.debug)
%         figure(fd_out);clf;
%         imshow(I);
%         draw_lines_parametric(fd_out,I, thetaP, rhoP);
%         hold on;
%         title('After rejecting outlier lines')
%     end
    
    % remove multiple lines per crop row
    [thetaP, rhoP] = filter_multiple_hough_lines(I,thetaP,rhoP);
    
    if(isfield(params,'debug') && params.debug)
        figure(fd_mult);clf;
        imshow(I);
        draw_lines_parametric(fd_mult,I, thetaP, rhoP);
        hold on;
        title('After removing mupltiple lines in a crop row')
    end
    
    % transform houglines to original image
    [thetaP, rhoP] = transform_hough_line_split_to_original(size(I_orig), i, num_image_splits, thetaP, rhoP);
    
    % collect detected lines from each split
    theta = [theta, thetaP];
    rho = [rho, rhoP];
end

if(isfield(params,'debug') && params.debug)
    fl_merge = figure;
    figure(fl_merge);clf;
    imshow(I_orig);
    draw_lines_parametric(fl_merge,I_orig, theta, rho);
    title('Merge all lines from individual splits')
end

% remove multiple lines per crop row (introduced due to split and merge)
[theta, rho] = filter_multiple_hough_lines(I,theta,rho);

if(isfield(params,'debug') && params.debug)
    fl_final = figure;
    figure(fl_final);clf;
    imshow(I_orig);
    draw_lines_parametric(fl_final,I_orig, theta, rho);
    title('After removing redundant lines after merging ')
end


end