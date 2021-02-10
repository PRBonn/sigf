% Compute the matchig score for two descriptors by rotating the reference
% point and choosing the best amongst it.
function score = match_score_rotated(D1, D2)

% length of desriptor
l = length(D1);

scores = zeros(1,l/2-1);
for i = 1 : l/2

% rotate D1 
D1_dist = circshift(D1(1:l/2),i-1);
D1_ori =  shift_descriptor_angles(D1(l/2+1:end),i-1);

D1_rotated = [D1_dist, D1_ori];

% compute score
scores(i) = match_score(D1_rotated, D2);

end

% get the best score
score = min(scores);

end