% This function draws lines for the given rho and theta values
function draw_lines_parametric(fl, I, theta_lines, rho_lines)
figure(fl);
for i = 1 : length(theta_lines)
    theta = theta_lines(i);
    rho = rho_lines(i);
    [pt1, pt2] = get_intersection_points_with_image_borders(I,theta,rho);
    
    if(~isempty(pt1) && ~isempty(pt2))
        figure(fl);
        hold on;
        plot([pt1(1),pt2(1)], [pt1(2),pt2(2)],'LineWidth',2);
    end
end

end
