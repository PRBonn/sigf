function score = match_score_weighted(D1,D2)

l = length(D1);
delta_dist = abs(D1(1:l/2) - D2(1:l/2));
delta_ang = abs(D1(l/2+1:end) - D2(l/2+1:end)); 

for i  = 1: length(delta_ang)
      delta_ang(i) = min(delta_ang(i),1-delta_ang(i));    
end

% choose weight in a better way
weight = (D1(1:l/2)+ D2(1:l/2))/2;
weight = ones(1,length(weight))./weight;

% scale angle differences by weight
delta_ang = delta_ang.*weight; 
score = norm([delta_dist,delta_ang]);

end