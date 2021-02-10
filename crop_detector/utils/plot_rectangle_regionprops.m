function plot_rectangle_regionprops(s)

for k = 1:length(s)
   rectangle('Position', s(k).BoundingBox, 'EdgeColor','r', 'LineWidth', 2)
end

end