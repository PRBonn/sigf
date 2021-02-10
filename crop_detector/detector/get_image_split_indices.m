% This function gives the indices for vertically splitting images.
function indices = get_image_split_indices(I_size, num_splits)
H = I_size(1);
W = I_size(2);
indices = zeros(num_splits,2);

for i = 1 : num_splits   
    indices(i,1) = floor((i-1)*(W/num_splits)) + 1;
    indices(i,2) = floor(i*(W/num_splits));
end

end