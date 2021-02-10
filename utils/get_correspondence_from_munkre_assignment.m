% This function intreprets assignment made by the munkres algorithm and
% computes the correspondences from it.
% Input:
%       A:  Assignment vector computed by munkres algorithm
%       N1: # of rows of cost matrix
%       N2: # of columns of cost matrix
% Output:
%       C:  correspondences (2xM)
function C = get_correspondence_from_munkre_assignment(A,N1,N2)

C = [];
for i = 1 : N1
    if(A(i)~=0 && A(i)<= N2)
        C = [C, [i,A(i)]'];
    end
end


% for i = 1 : length(A)
%     if (N1 < N2)
%         if(A(i)~=0 && A(i)<= N2)
%             C = [C, [i,A(i)]'];
%         end
%     else
%         if(A(i)~=0 && A(i)<= N1)
%             C = [C, [A(i),i]'];
%         end
%     end
%     
% end

end