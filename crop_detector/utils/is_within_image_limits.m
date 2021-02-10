function status = is_within_image_limits(I,p)
h = size(I,1);
w = size(I,2);

if (p(1)>=1 && p(1)<=w && p(2)>=1 && p(2)<= h)
    status =  true;
else
    status = false;
end