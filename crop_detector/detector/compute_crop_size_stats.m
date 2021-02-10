% Compute a histogram of crop sizes for a image
function stats = compute_crop_size_stats(M)

% compute crop sizes
regions = regionprops(M,'Centroid','Area','BoundingBox','MajorAxisLength', 'MinorAxisLength','EquivDiameter','Orientation');
num_crops = length(regions);
crop_sizes = zeros(1, num_crops);
for i = 1 : num_crops 
   crop_sizes(i) =  regions(i).Area;
end

% to hold stats computed form image mask
stats = [];
if(num_crops == 0)
    return;
end

% get the typical crop in the image
% use median crop size
[~, idx_sorted] = sort(crop_sizes);
idx_crop = idx_sorted(ceil(num_crops/2));

% use crop size with maximum frequency
% [size_freq,size_bins] = histcounts(crop_sizes,50);
% [~, ind_best_size] = max(size_freq);
% best_size = (size_bins(ind_best_size) + size_bins(ind_best_size+1))/2;
% [~,idx_crop] = min(abs(crop_sizes-best_size)); 

% collect stats about the 'typical' crop in the image
stats.crop_region = regions(idx_crop);
stats.crop_centroid = regions(idx_crop).Centroid; 
stats.crop_size = regions(idx_crop).Area;
stats.crop_bbox = regions(idx_crop).BoundingBox;
stats.crop_major_axis = regions(idx_crop).MajorAxisLength;
stats.crop_minor_axis = regions(idx_crop).MinorAxisLength;
stats.crop_diameter = regions(idx_crop).EquivDiameter;
stats.crop_orientation = regions(idx_crop).Orientation;
stats.crop_centroid = regions(idx_crop).Centroid;
 
% collect region properties for all objects
stats.regions = regions; 

% collect the statistics 
stats.min_size =  min(crop_sizes);
stats.max_size = max(crop_sizes);
stats.mean_size = mean(crop_sizes);
stats.median_size = median(crop_sizes);

end

