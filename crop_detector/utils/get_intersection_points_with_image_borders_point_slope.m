% This function computes
function [p1, p2] = get_intersection_points_with_image_borders_point_slope(I,p,m)

h = size(I,1);
w = size(I,2);

% image borders
x0 = 1; xw = w;
y0 = 1; yh = h;

% compute line intercept
c = p(2) - m*p(1);

% compute intersection with all four borders
P = zeros(4,2);
P(1,:) = [(y0-c)/m , y0];
P(2,:) = [xw, m*xw + c];
P(3,:) =  [(yh-c)/m ,yh];
P(4,:) = [x0, m*x0 + c];


idx = [];
for i = 1 : 4
    if (P(i,1) > 0 && P(i,1) <=w && P(i,2) > 0 && P(i,2)<=h )
        idx  = [idx,i];
    end
end

p1 = [];
p2 = [];
if(length(idx)==2)
    p1 = round(P(idx(1),:));
    p2 = round(P(idx(2),:));
end

end