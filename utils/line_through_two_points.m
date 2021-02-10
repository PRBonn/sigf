% function to compute the line passing through two points in homogeneous 
% coordinates
function l = line_through_two_points(x,xp)
    l = cross(x,xp);
end