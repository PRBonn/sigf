function [fh1, fh2] =  show_corresponding_points(I1,I2, P1, P2, M)

fh1 = figure;
figure(fh1);
imshow(I1);
hold on;
plot(P1(1,:), P1(2,:),'.b','MarkerSize',20);
for i = 1 : length(M)
    text(P1(1,M(1,i))+ 10,P1(2,M(1,i)),num2str(i),'Color', [0.8 0.1 0.1],'FontSize',14);
end
title('Image 1')


fh2 = figure;
figure(fh2);
imshow(I2);
hold on;
plot(P2(1,:), P2(2,:),'.b','MarkerSize',20);
for i = 1 : length(M)
    text(P2(1,M(2,i)) + 10 ,P2(2,M(2,i)),num2str(i),'Color', [0.8 0.1 0.1],'FontSize',14);
end
title('Image 2')

end