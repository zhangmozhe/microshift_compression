function code = image_arithmetic(I, w)
% arithmetic encoding for image
% comp: final code
% avglen: average code length

I = I';
I = I(:);
I = I / w + 1;

symbols = unique(I);
counts = hist(I, symbols);
code = arithenco(I, counts);
