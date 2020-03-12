function [I_quant_outputs, I_quant, distortion_pad] = PSD_compress(I, bitnum, pattern_size, modulo)
% I_quant_output: subimages
% I_quant: direct PSD output
% distortion_pad: padded distortion array

%% parameters
if nargin < 2
    bitnum = 3; % bitdepth
end
if nargin < 3
    pattern_size = 3; % pattern size
end
if nargin < 4
    modulo = 1;
end
if pattern_size == 3
    pattern_norm = [0, 1, 2, 5, 4, 3, 6, 7, 8];
end
if pattern_size == 4
    pattern_norm = [0, 1, 2, 3, 7, 6, 5, 4, 8, 9, 10, 11, 15, 14, 13, 12];
end
if pattern_size == 5
    pattern_norm = [0, 1, 2, 3, 4, 9, 8, 7, 6, 5, 10, 11, 12, 13, 14, 19, 18, 17, 16, 15, 20, 21, 22, 23, 24];
end

%%
I = double(I);
thresh = [1:(2^bitnum - 1)] * (256 / 2^bitnum) - 1;
w = 256 / (2^bitnum); % quantization error
pattern_norm = reshape(pattern_norm, [pattern_size, pattern_size])';
[height, width] = size(I);

%% perform PSD algorithm
distortion_pad = pattern(pattern_size, height, width, w, pattern_norm);
I_pad = I;
pad_num = ceil((pattern_size - 1)/2);
for i = 1:pad_num
    I_pad = padarray(I_pad, [1, 1], 'replicate', 'both'); % pad image
end
I_distortion_pad = I_pad + distortion_pad; % add microshifts
if modulo
    I_distortion_pad(I_distortion_pad >= 256) = I_distortion_pad(I_distortion_pad >= 256) - 256;
end
quant = imquantize(I_distortion_pad, thresh); % quantize the microshift image
I_quant = (256 / (2^bitnum)) * (quant - 1); % normalize to [0,255]

%% generate output cell
subimage_num = pattern_size * pattern_size;
I_quant_outputs = cell(1, subimage_num);
height1 = floor(height/3) * 3;
width1 = floor(width/3) * 3;

if pattern_size == 3
    I_quant_outputs{1} = uint8(I_quant(1:3:height1, 1:3:width1));
    I_quant_outputs{2} = uint8(I_quant(1:3:height1, 2:3:width1));
    I_quant_outputs{3} = uint8(I_quant(1:3:height1, 3:3:width1));
    I_quant_outputs{4} = uint8(I_quant(2:3:height1, 3:3:width1));
    I_quant_outputs{5} = uint8(I_quant(2:3:height1, 2:3:width1));
    I_quant_outputs{6} = uint8(I_quant(2:3:height1, 1:3:width1));
    I_quant_outputs{7} = uint8(I_quant(3:3:height1, 1:3:width1));
    I_quant_outputs{8} = uint8(I_quant(3:3:height1, 2:3:width1));
    I_quant_outputs{9} = uint8(I_quant(3:3:height1, 3:3:width1));
end
if pattern_size == 4
    I_quant_outputs{1} = uint8(I_quant(1:4:height1, 1:4:width1));
    I_quant_outputs{2} = uint8(I_quant(1:4:height1, 2:4:width1));
    I_quant_outputs{3} = uint8(I_quant(1:4:height1, 3:4:width1));
    I_quant_outputs{4} = uint8(I_quant(1:4:height1, 4:4:width1));
    I_quant_outputs{5} = uint8(I_quant(2:4:height1, 4:4:width1));
    I_quant_outputs{6} = uint8(I_quant(2:4:height1, 3:4:width1));
    I_quant_outputs{7} = uint8(I_quant(2:4:height1, 2:4:width1));
    I_quant_outputs{8} = uint8(I_quant(2:4:height1, 1:4:width1));
    I_quant_outputs{9} = uint8(I_quant(3:4:height1, 1:4:width1));
    I_quant_outputs{10} = uint8(I_quant(3:4:height1, 2:4:width1));
    I_quant_outputs{11} = uint8(I_quant(3:4:height1, 3:4:width1));
    I_quant_outputs{12} = uint8(I_quant(3:4:height1, 4:4:width1));
    I_quant_outputs{13} = uint8(I_quant(4:4:height1, 4:4:width1));
    I_quant_outputs{14} = uint8(I_quant(4:4:height1, 3:4:width1));
    I_quant_outputs{15} = uint8(I_quant(4:4:height1, 2:4:width1));
    I_quant_outputs{16} = uint8(I_quant(4:4:height1, 1:4:width1));
end
if pattern_size == 5
    I_quant_outputs{1} = uint8(I_quant(1:5:height1, 1:5:width1));
    I_quant_outputs{2} = uint8(I_quant(1:5:height1, 2:5:width1));
    I_quant_outputs{3} = uint8(I_quant(1:5:height1, 3:5:width1));
    I_quant_outputs{4} = uint8(I_quant(1:5:height1, 4:5:width1));
    I_quant_outputs{5} = uint8(I_quant(1:5:height1, 5:5:width1));
    I_quant_outputs{6} = uint8(I_quant(2:5:height1, 5:5:width1));
    I_quant_outputs{7} = uint8(I_quant(2:5:height1, 4:5:width1));
    I_quant_outputs{8} = uint8(I_quant(2:5:height1, 3:5:width1));
    I_quant_outputs{9} = uint8(I_quant(2:5:height1, 2:5:width1));
    I_quant_outputs{10} = uint8(I_quant(2:5:height1, 1:5:width1));
    I_quant_outputs{11} = uint8(I_quant(3:5:height1, 1:5:width1));
    I_quant_outputs{12} = uint8(I_quant(3:5:height1, 2:5:width1));
    I_quant_outputs{13} = uint8(I_quant(3:5:height1, 3:5:width1));
    I_quant_outputs{14} = uint8(I_quant(3:5:height1, 4:5:width1));
    I_quant_outputs{15} = uint8(I_quant(3:5:height1, 5:5:width1));
    I_quant_outputs{16} = uint8(I_quant(4:5:height1, 5:5:width1));
    I_quant_outputs{17} = uint8(I_quant(4:5:height1, 4:5:width1));
    I_quant_outputs{18} = uint8(I_quant(4:5:height1, 3:5:width1));
    I_quant_outputs{19} = uint8(I_quant(4:5:height1, 2:5:width1));
    I_quant_outputs{20} = uint8(I_quant(4:5:height1, 1:5:width1));
    I_quant_outputs{21} = uint8(I_quant(5:5:height1, 1:5:width1));
    I_quant_outputs{22} = uint8(I_quant(5:5:height1, 2:5:width1));
    I_quant_outputs{23} = uint8(I_quant(5:5:height1, 3:5:width1));
    I_quant_outputs{24} = uint8(I_quant(5:5:height1, 4:5:width1));
    I_quant_outputs{25} = uint8(I_quant(5:5:height1, 5:5:width1));
end
