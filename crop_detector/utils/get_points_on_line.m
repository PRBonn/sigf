% gets all the points on the line joiing p1 and p2
function [x,y] = get_points_on_line(p1,p2,del)

x1 = p1(1); y1 = p1(2);
x2 = p2(1); y2 = p2(2);

a =  y1-y2;
b =  x2-x1;
c = (x1-x2)*y1 + (y2-y1)*x1;
 
if (b==0)
    % vertical line case
    %fprintf('Vertical line ... \n')
    y = [min(y1,y2) : del : max(y1,y2)];
    x = x1*ones(1,length(y));
elseif (a==0)
    % horizontal line case
    x = [min(x1,x2) : del : max(x1,x2)];
    y = y1.*ones(1,length(x));
else
    % arbitrary line
    num_x = max(x1,x2) - min(x1,x2); 
    num_y = max(y1,y2) - min(y1,y2);
    
    if(num_x > num_y)
        x = [min(x1,x2) : del : max(x1,x2)];
        y = (-a/b)*x - (c/b);
    else
        y = [min(y1,y2) : del : max(y1,y2)]; 
        x = (-b/a)*y - (c/a);        
    end
end
       
        
x = x';
y = y';
end