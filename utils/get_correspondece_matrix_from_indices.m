function C =  get_correspondece_matrix_from_indices(ind1, ind2)
N1 = size(ind1,2);
N2  = size(ind2,2);
C = [];
for i = 1:N1
    j = find(ind2==ind1(i));
    if(~isempty(j))
        C = [C, [i,j]'];
    end
end

end