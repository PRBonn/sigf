% This function computes the crop pixels distribution along the crop row
% directions.
function [points, distribution]  = compute_crop_row_histogram(I,theta,rho)

%addpath('../external/bresenham');
%addpath('../utils')

% params
del_r = 20; % crop row width
del_c = 1; % resolution to search for crop centers

%%display the lines parallel to crop row
%rho1 = rho - del_r;
%rho2 = rho + del_r;
%theta_all = [theta, theta, theta];
%rho_all = [rho1, rho, rho2];
%fh = figure;
%imshow(I); hold on;
%draw_lines_parametric(fh, I, theta_all, rho_all);

% compute intersection points with the image borders
[p1, p2] = get_intersection_points_with_image_borders(I,theta,rho);

% slope for crop row line
if(isempty(p1) || isempty(p2))
    points = [];
    distribution = [];
    return;
end
m_row = (p2(2)-p1(2))/ (p2(1)-p1(1));

% % slope for line perpendicular to the crop row
m_per = -1/m_row;

% debug
% p_mid = (p1 + p2)/2;
% draw_lines_point_slope(fh, I, p_mid, m_per)
% theta_per = atan(m_per);
% q1 = [p_mid(1) + del_r*cos(theta_per), p_mid(2) + del_r*sin(theta_per)];
% q2 = [p_mid(1) - del_r*cos(theta_per), p_mid(2) - del_r*sin(theta_per)];
% [xc,yc] = bresenham(q1(1),q1(2),q2(1),q2(2));
% hold on;
% plot([q1(1) q2(1)], [q1(2) q2(2)], 'x')
% plot(xc, yc, '.')
% ind_c = sub2ind(size(I),size(I,1)-yc,xc);

% get points along the crop row
[xl,yl] = get_points_on_line(p1,p2,del_c);
distribution = zeros(size(xl,1),1);

for i = 1 : length(xl)
    
    % get intersection points with row edge lines
    theta_per = atan(m_per);
    q1 = [xl(i) + del_r*cos(theta_per), yl(i) + del_r*sin(theta_per)];
    q2 = [xl(i) - del_r*cos(theta_per), yl(i) - del_r*sin(theta_per)];
    
    
    if (is_within_image_limits(I,q1) && is_within_image_limits(I,q2) )
        % get pixels falling on this line
        [xc,yc] = bresenham(q1(1),q1(2),q2(1),q2(2));
        
        %compute crop pixels along this line
        ind_c = sub2ind(size(I),yc,xc);
        distribution(i) = sum(I(ind_c));
        
    end
end

points = [xl,yl];

end