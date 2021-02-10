% This function computes the crop size by allowing the user to draw a box
% around the 'model' crop.
function cinfo = compute_crop_size_manual(M)
% get median size crop for reference
stats = compute_crop_size_stats(M);

% select model crop manually
fman = figure;
figure(fman); clf;
imshow(M);
hold on;
plot_rectangle_regionprops(stats.crop_region);
title('Choose the model crop by drawing a rectangle around it.')

% if auto crop size looks good, then use it.
ukey = input('Is auto detected crop ok?','s');
if(isempty(ukey))
    cinfo.crop_size = stats.crop_size;
    cinfo.crop_diameter = stats.crop_diameter;
    cinfo.crop_bbox = stats.crop_bbox;
    cinfo.crop_major_axis = stats.crop_major_axis;
    cinfo.crop_minor_axis = stats.crop_minor_axis;
    cinfo.crop_orientation = stats.crop_orientation;
    cinfo.crop_centroid = stats.crop_centroid;
    close(fman);
    return;
end

figure(fman);
h = imrect;
M_crop_mask = createMask(h);
close(fman);
M_crop = imbinarize(M.*M_crop_mask);

% get regions in the selected area
regions = regionprops(M_crop,'Centroid','Area','BoundingBox','MajorAxisLength', 'MinorAxisLength','EquivDiameter','Orientation');
num_crops = length(regions);
crop_sizes = zeros(1, num_crops);
for i = 1 : num_crops
    crop_sizes(i) =  regions(i).Area;
end

% use the biggest region in the selected area as the crop
[~, idx_sorted] = sort(crop_sizes);
idx_crop = idx_sorted(end);
crop_region = regions(idx_crop);

% set crop info
cinfo.crop_size = crop_region.Area;
cinfo.crop_diameter = regions(idx_crop).EquivDiameter;
cinfo.crop_bbox = regions(idx_crop).BoundingBox;
cinfo.crop_major_axis = regions(idx_crop).MajorAxisLength;
cinfo.crop_minor_axis = regions(idx_crop).MinorAxisLength;
cinfo.crop_orientation = regions(idx_crop).Orientation;
cinfo.crop_centroid = regions(idx_crop).Centroid;

end