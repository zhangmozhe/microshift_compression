function [comp,avglen] = image_huffman(I)
% huffman encoding for image
% comp: final code
% avglen: average code length
I = I';
I = I(:);

symbols = unique(I);
counts = hist(I, symbols);
p = double(counts) ./ sum(counts);
[dict,avglen] = huffmandict(symbols,p);
comp = huffmanenco(I,dict);



