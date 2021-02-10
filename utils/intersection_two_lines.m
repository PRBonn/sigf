% function to compute intersection of two lines in homogeneous coordinates.
function x = intersection_two_lines(l,lp)
    x = cross(l,lp);
end