% This function shows the matched points between two point-sets given the 
% correspondences
%function f = show_matched_points(P1,P2,C)
function show_matched_points(P1,P2,C)

% Shift point set two for visualization
P2s = P2;
%P2s(1,:) = P2s(1,:) + (max(P2(1,:)) + 100);
P2s(1,:) = P2s(1,:) + (max(P2(1,:)) + 640);
%f = figure;
hold on;
plot(P1(1,:),P1(2,:),'.b', 'MarkerSize',10)
plot(P2s(1,:),P2s(2,:),'.r', 'MarkerSize',10)

for i = 1 : length(C)
    x1 = P1(1,C(i,1)); y1 = P1(2,C(i,1));   
    x2 = P2s(1,C(i,2)) ; y2 = P2s(2,C(i,2));
    plot([x1,x2],[y1,y2],'g')
end

end


