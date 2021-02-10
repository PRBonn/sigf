%  Function which transforms the points given new image size
%  (assuming cropped at the center)
function Pt = transform_points_new_size(P, old_size, new_size)

% Number of points
N = size(P,2);

% read image sizes
old_height = old_size(1);
old_width = old_size(2);
new_height = new_size(1);
new_width = new_size(2);

% Apply change in coordinate origins
dx = (old_width - new_width)/2;
dy = (old_height - new_height)/2;
P_new = P - [dx;dy];

% Remove points outside new size
Pt = [];
for i = 1 : N
    p = P_new(:,i);
    if(p(1)>=1 && p(1)<=new_width && p(2)>=1 && p(2)<= new_height)
        Pt = [Pt, p];
    end
end

end