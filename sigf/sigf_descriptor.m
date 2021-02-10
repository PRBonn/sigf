% This function computes the scale invariant geometric feature for a given set
% of points. The descriptor consists of [ratio of distances, angles].
% Input:
%       p: point for which feature is computed
%       kP: k nearest neighbours of the point
%       params:
%           ref: point to be used as reference (far/stable)
%           order: how to order the elements of the descriptor (ori/dist)
%           number_of_bins : if >0, a variant with a fixed number of
%                           bins is used. No angle values are in
%                           the descriptor, the bins represent the angles
%                           around the central point.
%           use_all_as_reference: if present and true, then for the bin
%                                 variant, every point is used as a
%                                 reference, so that the actual descriptor
%                                 has length
%                                 number_of_points*number_of_bins
% Output:
%       D: A descriptor containing (k-1) distance ratios and (k-1) angle
%       differences

% To Do:
% 1. Also return reference point + neighbour indices (for debugging).

function [D, indD, ind_ref] =  sigf_descriptor(p,kP, params)
% Read parameters
ref = params.ref;

if isfield(params,'order')
    order = params.order;
else
    order = '';
end

if isfield(params,'number_of_bins')
    number_of_bins=params.number_of_bins;
else
    number_of_bins=0;
end

% Define inline function for wrapped loop variable for an array
wrapN = @(x, N) (1 + mod(x-1, N));

N = size(kP,2); % # of neigbours

% 1. shift the origin to point p
P0 = kP - repmat(p',N,1)';

% 2. convert to polar coordinates
[theta_P, rho_P]= cart2pol(P0(1,:), P0(2,:));

% 3. sort points both by distance from origin and angle
[sorted_rho, ind_rho]= sort(rho_P);
[~, ind_theta] = sort(theta_P);


% 4. compute the reference point
% use farthest point as reference
if (strcmp(ref,'far'))
    ind_ref = ind_rho(end);
    dist_max = rho_P(ind_ref);
    i0 = find(ind_theta==ind_ref);
end

% switches between nearest and farthest as reference based on which is more
% 'stable'
if(strcmp(ref,'stable'))
    cond_far = sorted_rho(end)/sorted_rho(end-1);
    cond_near = sorted_rho(2)/sorted_rho(1);
    if cond_far > cond_near
        ind_ref = ind_rho(end);
    else
        ind_ref = ind_rho(1);
    end
    i0 = find(ind_theta==ind_ref);
    dist_max = sorted_rho(end);
end


% initialize the descriptor
nD = N-1;
D1 = zeros(1,nD);
D2 = zeros(1,nD);
indD = zeros(1,nD);

% 5a. Pre-ordered points
if(strcmp(order,'ideal'))
    ind_ref = 1;
    for i = 1 : nD
        % compute distance ratios
        D1(i) = rho_P(i)/dist_max;
        % compute angles from reference vector (normalize by 2*pi)
        D2(i) = wrapTo2Pi(theta_P(i) - theta_P(1))/(2*pi);
        indD(i) = i;        
    end
    D = [D1,D2];
end


% 5b. Order the descriptor by orientation
if (strcmp(order,'ori'))
    %  compute the descriptor
    for i = 1 : nD
        ii = wrapN(i0+i,length(ind_theta));
        ind = ind_theta(ii);
        % compute distance ratios
        D1(i) = rho_P(ind)/dist_max;
        % compute angles from reference vector (normalize by 2*pi)
        D2(i) = wrapTo2Pi(theta_P(ind) - theta_P(ind_ref))/(2*pi);
        indD(i) = ind;
    end
    D = [D1,D2];
end

% 5c. Order the descriptor by distance
if (strcmp(order,'dist'))
    % far/stable (same impl for both)
    if (strcmp(ref,'far') || strcmp(ref,'stable') )
        ind_ref = ind_rho(end);
        dist_max = sorted_rho(end);
        for i = 1 : nD
            % compute distance ratios
            D1(i) = sorted_rho(i)/dist_max;
            % get the corresponding index of the point
            ind = ind_rho(i);
            % compute angles from reference vector (normalize by 2*pi)
            D2(i) = wrapTo2Pi(theta_P(ind) - theta_P(ind_ref))/(2*pi);
            indD(i) = ind;
        end
    end
    D = [D1,D2];
end


% 5d. compute bin based descriptor
if (number_of_bins > 0)
    % Fixed bin variant
    if isfield(params,'use_all_as_reference') && params.use_all_as_reference
        D=zeros(N*number_of_bins,1);
        for i=1:N
            D((i-1)*number_of_bins+1:(i-1)*number_of_bins+number_of_bins)=calculate_fixed_bins(N, number_of_bins, i, dist_max, theta_P, rho_P);
            indD = ind_rho; % To be changed
        end
    else
        D=calculate_fixed_bins(N, number_of_bins, ind_ref, dist_max, theta_P, rho_P);
        indD = ind_rho; % To be changed
    end
end


end


function bins=calculate_fixed_bins(N, number_of_bins, ind_ref, dist_max, theta_P, rho_P)
% Set the 0 angle to the chosen reference point, and wrap to values
% between 0 and 2*pi
theta_transformed=wrapTo2Pi(theta_P - theta_P(ind_ref));
bin_size=2*pi/number_of_bins;
bin_centers=0:bin_size:2*pi;
bin_centers=bin_centers(1:length(bin_centers)-1);
% borders of bin (in direction to smaller angles)
bin_borders=bin_centers-bin_size/2;

% Put points in bins
bins=zeros(number_of_bins,1);
for i=1:N
    bin_idx=floor((theta_transformed(i)+bin_size/2)/bin_size)+1;
    if (bin_idx>number_of_bins)
        bin_idx=1;
    end
    beta=theta_transformed(i)-bin_borders(bin_idx);
    if (beta>bin_size/2)
        r=(bin_size-beta)/bin_size;
        neighbour_idx=bin_idx+1;
        if (neighbour_idx>number_of_bins)
            neighbour_idx=1;
        end
    else
        r=beta/bin_size;
        neighbour_idx=bin_idx-1;
        if (neighbour_idx==0)
            neighbour_idx=number_of_bins;
        end
    end
    f_bin=r+0.5;
    f_neighbour=1-f_bin;
    bins(bin_idx)=bins(bin_idx)+f_bin*rho_P(i)/dist_max;
    bins(neighbour_idx)=bins(neighbour_idx)+f_neighbour*rho_P(i)/dist_max;
end
end