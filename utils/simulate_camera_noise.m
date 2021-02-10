% This function simulated  
% Input:
%       x: points in the image
%       ind: indices of the points
%       params: noise parameters
% Output:
%       x_noisy: noisy points in the image
%       ind_noisy: indices of the noisy points

function [x_noisy, ind_noisy] = simulate_camera_noise(x, ind, height, width, params)
N = size(x,2);
sigma_x = params.sigma_x;
sigma_y = params.sigma_y;

% add noise
x_(1,:) = x(1,:) + sigma_x*randn(1,N);
x_(2,:) = x(2,:) + sigma_y*randn(1,N);

x_noisy = [];
ind_noisy = []; 
for i = 1 : N
    x1 = x_(:,i);
    if (x1(1) > 0 && x1(1) <= width && x1(2) > 0 && x1(2) <= height)
        x_noisy = [x_noisy, x1];
        ind_noisy = [ind_noisy, ind(i)];
    end
end

end

