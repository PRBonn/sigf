% This function computes the sigf feature for each point in the set 
% and computes the descriptor.
% Input: 
%       P : set of all points
%       params : 
%            k : number of neighbouring points to consider for the descriptor 
% Output:
%       D : Descriptor matrix of size (# of points x k-1)

function D = sigf(P, params)
 
% number of points in the set.
N = size(P,2); 

% number of neighbours to consider
k = params.k; 

% initialize the descriptor matrix D 
if isfield(params,'number_of_bins') && params.number_of_bins>0
  if isfield(params,'use_all_as_reference') && params.use_all_as_reference
    D = zeros(N,params.k*params.number_of_bins);
  else
    D = zeros(N,params.number_of_bins);
  end
else
  D = zeros(N,2*(k-1));
end

for i = 1 : N
 % select a point   
 p = P(:,i);

 % get the neighbours
 [idx, ~] = knnsearch(P', p', 'k', k+1);
 ind_k = idx(2:k+1)';
 kP = P(:,ind_k);
 
 % compute the descriptor for this point
 D(i,:) = sigf_descriptor(p, kP, params);

end

end