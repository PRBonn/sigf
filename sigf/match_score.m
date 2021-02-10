function score = match_score(D1, D2)

% length of desriptor
l = length(D1);

% compute deltas
delta_dist = abs(D1(1:l/2) - D2(1:l/2)); 
delta_ang = abs(D1(l/2+1:end) - D2(l/2+1:end));

for i  = 1: length(delta_ang)
      delta_ang(i) = min(delta_ang(i),1-delta_ang(i));    
end

score = norm([delta_dist,delta_ang]);

end