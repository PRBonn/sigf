% This function simulates detection error of crop detection.
% Input:
%       x: points in the image
%       ind: indices of the points
%       err_perc: percentage of points effected by detection error
% Output:
%       x_noisy: noisy points in the image
%       ind_noisy: indices of the noisy points
% To Do:
% Simulate extra points

function [x_, ind_] = simulate_detection_errors(x, ind, err_perc)
N = size(x,2);

N_err = floor(err_perc*N);

% Simulate half errors as missing points
rand_ind = randperm(N);
del_ind = rand_ind(1:N_err);

x_ = [];
ind_ = []; 
for i = 1 : N
    x1 = x(:,i);
    if (isempty(find(del_ind==i)))
        x_ = [x_, x1];
        ind_ = [ind_, ind(i)];
    end
end

end

