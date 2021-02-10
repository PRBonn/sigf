% This function takes input a RGB image and outputs the vegetation mask 
% using the Excess Green Index (ExG).
function M = extract_vegetation_mask(I)

% Seperate color channels
Id = im2double(I);
R = Id(:,:,1);
G = Id(:,:,2);
B = Id(:,:,3);

% normalize and calculate vegetation index
nR = R/255;
nG = G/255;
nB = B/255;
normRGB = nR + nG + nB;
cR = nR./normRGB; 
cG = nG./normRGB;
cB = nB./normRGB;

VI = 2*cG - cR - cB;

% blur the VI mask
VI = imgaussfilt(VI,2);
%VI = medfilt2(VI);

% get vegetation mask
otsu_thresh = graythresh(VI);
M = imbinarize(VI, otsu_thresh);

% some morphological operations
% opening
SE = strel('disk',4);
M = imopen(M,SE);
%closing
M = imclose(M,SE);

end