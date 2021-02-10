% This function computes the mask around the crop row given the rho,theta
% represntation of the line.
function M_row = compute_crop_row_mask(M, theta, rho)
% params
del_r = 50; % crop row width

% initialize mask
h = size(M,1);
w = size(M,2);
M_row = zeros(h,w);

% compute intersection points with the image borders
[p1a, p2a] = get_intersection_points_with_image_borders(M,theta,rho-del_r);
[p1b, p2b] = get_intersection_points_with_image_borders(M,theta,rho+del_r);

if(~isempty(p1a) && ~isempty(p2a) && ~isempty(p1b) && ~isempty(p2b))
    x1a = p1a(1); y1a = p1a(2); x2a = p2a(1); y2a = p2a(2);
    x1b = p1b(1); y1b = p1b(2); x2b = p2b(1); y2b = p2b(2);
    
    % define polygon with these points
    polygonx = [x1a x2a x1b x2b];
    polygony = [y1a y2a y1b y2b];
    k = convhull(polygonx,polygony);
    
    % create a mask using the polygon
    M_row = poly2mask(polygonx(k),polygony(k),h,w);
    
else
    M_row = zeros(size(M));
end

end