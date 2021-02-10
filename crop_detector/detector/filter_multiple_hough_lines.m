% filter multiple lines passing through the same crop row
function [theta_inliers, rho_inliers] = filter_multiple_hough_lines(M,theta,rho)
% set thresholds
row_thresh = 60;

% compute the general orientation of the crop rows
theta_median = median(theta);
theta_thresh = deg2rad(20);

% Remove multiple lines passing through the same crop row
% 1. sort by distance
[rho_sorted, ind_rho_sorted]= sort(rho);
theta_by_rho = theta(ind_rho_sorted);

% 2. if two consecutive entries are with a threshold, consider as lines
% through the same crop row
rho_diff = rho_sorted(2:end) - rho_sorted(1:end-1);
row_check = rho_diff < row_thresh;

% 3. choose one of the two lines (somehow) and throw the other
idx_to_remove = false([1,length(rho)]);
for i = 1 : length(row_check)
    % do some checking and set idx of elements to be removed
    if (row_check(i) == 1)
        idx1 = i; idx2 = i+1;
        
        if (abs(theta_by_rho(idx1) - theta_by_rho(idx2)) < theta_thresh)
            
            % choose whichever is closer to the median direction of the crop rows
            theta1_off = abs(theta_by_rho(idx1) - theta_median);
            theta2_off = abs(theta_by_rho(idx2) - theta_median);
            
            if (theta1_off < theta2_off)
                idx = idx2;
            else
                idx = idx1;
            end
            
%             %choose whichever intersects more with the crop row pixels 
%             [~, hist1]  = compute_crop_row_histogram(M,theta(idx1),rho(idx1));
%             num_crop_pix1 = sum(hist1>0);
%             [~, hist2]  = compute_crop_row_histogram(M,theta(idx2),rho(idx2));
%             num_crop_pix2 = sum(hist2>0);
%             
%             if (num_crop_pix1 < num_crop_pix2)
%                 idx = idx1;
%             else
%                 idx = idx2;
%             end
          
            
        end
        idx_to_remove(idx) = true;
    end
    
end

theta_inliers = theta_by_rho(~idx_to_remove);
rho_inliers = rho_sorted(~idx_to_remove);

end
