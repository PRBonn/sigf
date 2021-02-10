% This function computes a list of inliers which fall within the matching
% radius using the hungarian method (which assigns only one correspondence
% per point).

function inliers = compute_inliers_greedy(P, Q, T, thresh)
addpath('../utils');

nP = size(P,2);
nQ = size(Q,2);

% Apply transformation to points in P
Q_hat = T*[P ; ones(1,nP)];
Q_hat = Q_hat(1:2,:);


%% Cost matrix (Type 1)
% Compute cost matrix given T (Euclidian distance)
% W = zeros(nP, nQ);
% for i = 1 : nP
%     q_hat = Q_hat(:,i);
%     for j = 1 : nQ
%         q = Q(:,j);
%         dist = norm(q_hat-q);
%         W(i,j) = dist;
%     end
% end

%% Cost matrix (Type 2)
%  Compute cost matrix given T (Euclidian distance + threshold)
W = zeros(nP, nQ);
for i = 1 : nP
    q_hat = Q_hat(:,i);
    for j = 1 : nQ
        q = Q(:,j);
        dist = norm(q_hat-q);
        if(dist < thresh)
            W(i,j) = dist;
        else
            W(i,j) = Inf;
        end
    end
end

%% Cost matrix (Type 3)
% Compute cost matrix given T (allow for non-assignments with some penalty)
% W = zeros(nP+nQ, nQ+nP);
% for i = 1 : nP
%     q_hat = Q_hat(:,i);
%     for j = 1 : nQ
%         q = Q(:,j);
%         dist = norm(q_hat-q);
%         if(dist < thresh)
%             W(i,j) = dist;
%         else
%             W(i,j) = Inf;
%         end
%     end
% end
% W(nP+1:nP+nQ,1:nQ+nP) = thresh; 
% W(1:nP, nQ+1:nQ+nP) = thresh;

% get optimal assignment and cost (hungarian method)
% if (nP < nQ)
%     [A, ~]  = munkres(W);
% else
%     [A, ~] = munkres(W');
% end

[A, ~]  = greedy_assignment(W);
inliers = get_correspondence_from_munkre_assignment(A,nP,nQ);


end