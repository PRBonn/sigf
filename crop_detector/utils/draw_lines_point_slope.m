% This function draws lines for the given slope
function draw_lines_point_slope(fl, I, points, slopes)

figure(fl);
for i = 1 : length(slopes)
    p = points(i,:);
    m = slopes(i);    
    [pt1, pt2] = get_intersection_points_with_image_borders_point_slope(I,p,m);
    hold on;
    plot([pt1(1),pt2(1)], [pt1(2),pt2(2)]);    
end

end