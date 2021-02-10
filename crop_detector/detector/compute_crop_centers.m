% This function computes the crop centers given the vegetation mask using the
% centroid .
function centers = compute_crop_centers(M, params)

% set parameters
if(isfield(params,'manual_mode') && params.manual_mode)
    cinfo = compute_crop_size_manual(M);
    avg_crop_size =   cinfo.crop_size;
    avg_crop_diameter = cinfo.crop_diameter;
    min_object_size = floor(cinfo.crop_size/4);
    max_object_size = floor(cinfo.crop_size*20);
    
else
    min_object_size = params.min_object_size;
    max_object_size = params.max_object_size;
    avg_crop_size =   params.crop_size;
    avg_crop_diameter = params.crop_diameter;
end

% 1) reject the really small and the really big objects
if(isfield(params,'debug') && params.debug)
    figure(100); hold on;
    imshow(M)
    title('Before applying size filter')
end

M = xor(bwareaopen(M,min_object_size), bwareaopen(M,max_object_size));

if(isfield(params,'debug') && params.debug)
    figure(101); hold on;
    imshow(M)
    title('After applying size filter')
end

% 2) compute region properties in the image
stats = compute_crop_size_stats(M);

% 3) compute centroids of objects in the mask
centers = [];
if(~isempty(stats))
    for i = 1 : length(stats.regions)
        if(stats.regions(i).Area > avg_crop_size) % condition to figure out if they are joined or not
            num_joint_crops_areawise = floor(stats.regions(i).Area/avg_crop_size);
            num_joint_crops_lengthwise = floor(stats.regions(i).MajorAxisLength/avg_crop_diameter);
            num_joint_crops = min(num_joint_crops_areawise, num_joint_crops_lengthwise);
            cc = compute_centers_joint_crops(stats.regions(i),num_joint_crops,'ellipse');
            centers = [centers; cc];
        else % plants are not joint
            centers = [centers; stats.regions(i).Centroid];
        end
    end
end
end

function cc = compute_centers_joint_crops(region, n, type)

if(strcmp(type,'bbox'))
    % compute using bounding box
    x0 = region.BoundingBox(1);
    y0 = region.BoundingBox(2);
    w  = region.BoundingBox(3);
    h  = region.BoundingBox(4);
    
    p1 = [x0 + w/2, y0];
    p2 = [x0 + w/2, y0 + h];
else
    % compute using major axis of the ellipse
    xc = region.Centroid(1);
    yc = region.Centroid(2);
    theta = deg2rad(region.Orientation);
    l = region.MajorAxisLength;
    
    p1 = [xc - (l/2)*cos(theta), yc - (l/2)*sin(theta)];
    p2 = [xc + (l/2)*cos(theta), yc + (l/2)*sin(theta)];
end

% compute equidistant points on this line
cc_x = linspace(p1(1), p2(1), n+2);
cc_y = linspace(p1(2), p2(2), n+2);
cc = [cc_x(2:end-1)', cc_y(2:end-1)'];

end