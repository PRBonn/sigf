% This function computes
function [p1, p2] = get_intersection_points_with_image_borders(I,theta,rho)

h = size(I,1);
w = size(I,2);

% image borders
x0 = 1; xw = w;
y0 = 1; yh = h;

% compute intersection with all four borders
P = zeros(4,2);
P(1,:) = [(rho - y0*sin(theta))/cos(theta), y0];
P(2,:) = [xw, (rho - xw*cos(theta))/sin(theta)];
P(3,:) =  [(rho - yh*sin(theta))/cos(theta) ,yh];
P(4,:) = [x0, (rho - x0*cos(theta))/sin(theta)];

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