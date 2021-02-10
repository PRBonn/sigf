% This fuction computes the matching score in a one vs all fashion and returns
% indices of matching pairs.
% Input:
%       D1: descriptor for point set 1
%       D2: descriptor for point set 2
%       params :
%            ratio: acceptance ratio for a correspondence
%            type: which type of measure to use for scoring
%            debug: print debug info
% Output:
%       index_pairs : list of matching point indices
% TO DO:
%       return scores for the computed matches

function index_pairs = match_sigf_features(D1,D2,params)

% read in matching parameters
ratio = params.ratio;
type  = params.type;

N1 = size(D1,1); % # of points in set 1
N2 = size(D2,1); % # of points in set 2

if (isfield(params,'use_prior') &&  params.use_prior && isfield(params,'C_prior'))
   C = params.C_prior;
else
   C = logical(ones(N1,N2));
end    

% compute matching scores
matchScores = Inf*ones(N1,N2);
if size(D2,2)>size(D1,2)
    % all as reference variant
    N3=size(D2,2)/size(D1,2);
    descrlength=size(D1,2);
    ref_sc=zeros(N3,1);
    for i = 1 : N1
        Ci = find(C(i,:)==1);
        for j = 1 : length(Ci)
            for k = 1 : N3
                ref_sc(k)= norm(D1(i,:)-D2(Ci(j),(k-1)*descrlength+1:(k-1)*descrlength+descrlength),2);
            end
            matchScores(i,Ci(j)) = min(ref_sc);
        end
    end
    
else
    for i = 1 : N1
        Ci = find(C(i,:)==1);
        for j = 1 : length(Ci)
            
            switch(type)
                case 'norm'
                    matchScores(i,Ci(j)) = norm(D1(i,:)-D2(Ci(j),:),2);
                case 'diff'
                    matchScores(i,Ci(j)) = match_score(D1(i,:),D2(Ci(j),:));
                case 'weighted'
                    matchScores(i,Ci(j)) = match_score_weighted(D1(i,:),D2(Ci(j),:));
                case 'rotated'
                    matchScores(i,Ci(j)) = match_score_rotated(D1(i,:),D2(Ci(j),:));
            end
            
        end
    end
end

% get matching index pairs
index_pairs = [];
N = min(N1,N2);
for i = 1 : N
    
    if(N1 < N2)
        [scores, ind]  = sort(matchScores(i,:));
        if( scores(1) < ratio*scores(2))
            j = ind(1);
            index_pairs = [index_pairs; i, j];
        end
        
    else
        [scores, ind]  = sort(matchScores(:,i));
        if( scores(1) < ratio*scores(2))
            j = ind(1);
            index_pairs = [index_pairs; j, i];
        end
    end
end

% Print status
if isfield(params,'debug') && params.debug
    fprintf('[Matching:] # of correspondences found = %d,\n', length(index_pairs));
end

end