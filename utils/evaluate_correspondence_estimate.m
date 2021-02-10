% This function counts the number of correspondences which have been estimated
% correctly
% Input:
%
% Output:
%       correct: number of correspondences estimated correctly.

function correct = evaluate_correspondence_estimate(C_est, C)
correct = 0;
N = size(C_est,2);

for i = 1:N
    m_est = C_est(:,i);
    ind = find(C(1,:)==m_est(1));
    m = C(:,ind);
    if (~isempty(m))
        if(m_est(1)==m(1) && m_est(2)==m(2) )
            correct = correct + 1;
        end
    end
end

end

