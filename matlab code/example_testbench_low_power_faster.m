function I_reconstruct = example_testbench_low_power_faster

%% read image
clear all % or clear variables
% compression_mode = 0: no compression;
% compression_mode = 1: compression without internal compression;
% compression_mode = 2: compression with internal compression;
% decompression_mode = 1: fast decompression
% decompression_mode = 2: MRF decompression

%% parameter setup
compression_mode = fi(2, 0, 2, 0);
decompression_mode = 1;
ActivePixels = 216;  % the height should be multiple of 3
ActiveLines = 256;
origIm = imread('input_images/elaine.bmp');

if ndims(origIm) == 3
    origIm = rgb2gray(origIm);
end
origIm = imresize(origIm, [256, ActivePixels]);
inputIm = origIm(1:ActiveLines, 1:ActivePixels);

if (compression_mode == 1)
    [~, inputIm] = PSD_compress(inputIm);
    inputIm = uint8(inputIm) / 32;
    inputIm = inputIm(1:ActiveLines, 1:ActivePixels);
end

%% output image data to the file
fileID = fopen('image.dat', 'w');
I_scan = inputIm';
I_scan = I_scan(:);
for i = 1:length(I_scan)
    fprintf(fileID, '%x\n', I_scan(i));
end
fclose(fileID);

%% frame to pixel
frm2pix = visionhdl.FrameToPixels( ...
    'NumComponents', 1, ... % grayscale or color
    'VideoFormat', 'custom', ... % custom size
    'ActivePixelsPerLine', ActivePixels, ...
    'ActiveVideoLines', ActiveLines, ...
    'TotalPixelsPerLine', ActivePixels+20, ... % pad 10 inactive pixels on the front and back of each line
    'TotalVideoLines', ActiveLines+5, ... % pad 5 inactive pixels above and below
    'StartingActiveLine', 1, ... % starting active line
    'FrontPorch', 10); % front porch

[~, ~, numPixelsPerFrame] = getparamfromfrm2pix(frm2pix); % get the total number of pixels including padding
[pixel, ctrl] = frm2pix(inputIm);
pixelOut = zeros(numPixelsPerFrame, 1, 'uint8');
ctrlOut = repmat(pixelcontrolstruct, numPixelsPerFrame, 1);

% per pixel hdl processing
encoded_bitstream1 = repmat(char(0), 1, numPixelsPerFrame*3);
encoded_bitstream2 = repmat(char(0), 1, numPixelsPerFrame*3);
encoded_bitstream3 = repmat(char(0), 1, numPixelsPerFrame*3);
encoded_bitstream4 = repmat(char(0), 1, numPixelsPerFrame*3);
encoded_bitstream5 = repmat(char(0), 1, numPixelsPerFrame*3);
encoded_bitstream6 = repmat(char(0), 1, numPixelsPerFrame*3);
encoded_bitstream7 = repmat(char(0), 1, numPixelsPerFrame*3);
encoded_bitstream8 = repmat(char(0), 1, numPixelsPerFrame*3);
encoded_bitstream9 = repmat(char(0), 1, numPixelsPerFrame*3);
bitstream_index1 = 0;
bitstream_index2 = 0;
bitstream_index3 = 0;
bitstream_index4 = 0;
bitstream_index5 = 0;
bitstream_index6 = 0;
bitstream_index7 = 0;
bitstream_index8 = 0;
bitstream_index9 = 0;

%% on-chp HDL compression
for pixel_index = 1:numPixelsPerFrame
    [hStart, hEnd, vStart, vEnd, valid] = pixelcontrolsignals(ctrl(pixel_index));
    pixelIn = pixel(pixel_index);
    [bitstream_ready, bitstream_length, subimage_index_delay, bitstream, hStart_output, hEnd_output, vStart_output, vEnd_output, valid_output] = compression_hdl_lowpower_mex(pixelIn, hStart, hEnd, vStart, vEnd, valid, compression_mode);

    % output to the corresponding bitstream buffer
    if (bitstream_ready)
        switch subimage_index_delay
            case 1
                encoded_bitstream1 = bitstream_store(encoded_bitstream1, bitstream, bitstream_length, bitstream_index1);
                bitstream_index1 = bitstream_index1 + bitstream_length;
            case 2
                encoded_bitstream2 = bitstream_store(encoded_bitstream2, bitstream, bitstream_length, bitstream_index2);
                bitstream_index2 = bitstream_index2 + bitstream_length;
            case 3
                encoded_bitstream3 = bitstream_store(encoded_bitstream3, bitstream, bitstream_length, bitstream_index3);
                bitstream_index3 = bitstream_index3 + bitstream_length;
            case 4
                encoded_bitstream4 = bitstream_store(encoded_bitstream4, bitstream, bitstream_length, bitstream_index4);
                bitstream_index4 = bitstream_index4 + bitstream_length;
            case 5
                encoded_bitstream5 = bitstream_store(encoded_bitstream5, bitstream, bitstream_length, bitstream_index5);
                bitstream_index5 = bitstream_index5 + bitstream_length;
            case 6
                encoded_bitstream6 = bitstream_store(encoded_bitstream6, bitstream, bitstream_length, bitstream_index6);
                bitstream_index6 = bitstream_index6 + bitstream_length;
            case 7
                encoded_bitstream7 = bitstream_store(encoded_bitstream7, bitstream, bitstream_length, bitstream_index7);
                bitstream_index7 = bitstream_index7 + bitstream_length;
            case 8
                encoded_bitstream8 = bitstream_store(encoded_bitstream8, bitstream, bitstream_length, bitstream_index8);
                bitstream_index8 = bitstream_index8 + bitstream_length;
            case 9
                encoded_bitstream9 = bitstream_store(encoded_bitstream9, bitstream, bitstream_length, bitstream_index9);
                bitstream_index9 = bitstream_index9 + bitstream_length;
            otherwise
                disp('other subimage index');
        end
    end
end

encoded_bitstream1 = encoded_bitstream1(1:bitstream_index1);
encoded_bitstream2 = encoded_bitstream2(1:bitstream_index2);
encoded_bitstream3 = encoded_bitstream3(1:bitstream_index3);
encoded_bitstream4 = encoded_bitstream4(1:bitstream_index4);
encoded_bitstream5 = encoded_bitstream5(1:bitstream_index5);
encoded_bitstream6 = encoded_bitstream6(1:bitstream_index6);
encoded_bitstream7 = encoded_bitstream7(1:bitstream_index7);
encoded_bitstream8 = encoded_bitstream8(1:bitstream_index8);
encoded_bitstream9 = encoded_bitstream9(1:bitstream_index9);
total_bitstream = bitstream_index1 + bitstream_index2 + bitstream_index3 ...
    + bitstream_index4 + bitstream_index5 + bitstream_index6 + bitstream_index7 ...
    + bitstream_index8 + bitstream_index9;
compression_ratio = (ActivePixels * ActiveLines) * 8 / double(total_bitstream);

%% pixel outputs to frame: PSD quantization image
pix2frm = visionhdl.PixelsToFrame( ...
    'NumComponents', 1, ...
    'VideoFormat', 'custom', ...
    'ActivePixelsPerLine', ActivePixels, ...
    'ActiveVideoLines', ActiveLines);

[outputIm, validIm] = pix2frm(pixelOut, ctrlOut);
outputIm = inputIm;
pattern_norm = [0, 1, 2, 5, 4, 3, 6, 7, 8];
pattern_norm = reshape(pattern_norm, [3, 3])';
distortion_pad = pattern(3, ActiveLines, ActivePixels, 32, pattern_norm);
distortion = distortion_pad(1:ActiveLines, 1:ActivePixels);
thresh = [1:(2^3 - 1)] * (256 / 2^3) - 1;
quant = imquantize(double(distortion)*(-1)+double(outputIm), thresh);
outputIm = (256 / (2^3)) * (quant - 1);

%% Microshift decompression
width_mod = mod(ActivePixels, 3);
height_mod = mod(ActiveLines, 3);
switch width_mod
    case 0
        col1_more = 0;
        col2_more = 0;
        col3_more = 0;
    case 1
        col1_more = 1;
        col2_more = 0;
        col3_more = 0;
    case 2
        col1_more = 1;
        col2_more = 1;
        col3_more = 0;
end
switch height_mod
    case 0
        row1_more = 0;
        row2_more = 0;
        row3_more = 0;
    case 1
        row1_more = 1;
        row2_more = 0;
        row3_more = 0;
    case 2
        row1_more = 1;
        row2_more = 1;
        row3_more = 0;
end
width1 = floor(ActivePixels/3) + col1_more;
height1 = floor(ActiveLines/3) + row1_more;
width2 = floor(ActivePixels/3) + col2_more;
height2 = floor(ActiveLines/3) + row1_more;
width3 = floor(ActivePixels/3) + col3_more;
height3 = floor(ActiveLines/3) + row1_more;
width4 = floor(ActivePixels/3) + col3_more;
height4 = floor(ActiveLines/3) + row2_more;
width5 = floor(ActivePixels/3) + col2_more;
height5 = floor(ActiveLines/3) + row2_more;
width6 = floor(ActivePixels/3) + col1_more;
height6 = floor(ActiveLines/3) + row2_more;
width7 = floor(ActivePixels/3) + col1_more;
height7 = floor(ActiveLines/3) + row3_more;
width8 = floor(ActivePixels/3) + col2_more;
height8 = floor(ActiveLines/3) + row3_more;
width9 = floor(ActivePixels/3) + col3_more;
height9 = floor(ActiveLines/3) + row3_more;

I_subimages = cell(9, 1);
I1 = decompression_hdl(encoded_bitstream1, height1, width1, outputIm(1:3:end, 1:3:end), 1, I_subimages);
I_subimages{1} = I1; 
I2 = decompression_hdl(encoded_bitstream2, height2, width2, outputIm(1:3:end, 2:3:end), 2, I_subimages);
I_subimages{2} = I2; 
I3 = decompression_hdl(encoded_bitstream3, height3, width3, outputIm(1:3:end, 3:3:end), 3, I_subimages);
I_subimages{3} = I3; 
I4 = decompression_hdl(encoded_bitstream4, height4, width4, outputIm(2:3:end, 3:3:end), 4, I_subimages);
I_subimages{4} = I4; 
I5 = decompression_hdl(encoded_bitstream5, height5, width5, outputIm(2:3:end, 2:3:end), 5, I_subimages);
I_subimages{5} = I5; 
I6 = decompression_hdl(encoded_bitstream6, height6, width6, outputIm(2:3:end, 1:3:end), 6, I_subimages);
I_subimages{6} = I6; 
I7 = decompression_hdl(encoded_bitstream7, height7, width7, outputIm(3:3:end, 1:3:end), 7, I_subimages);
I_subimages{7} = I7; 
I8 = decompression_hdl(encoded_bitstream8, height8, width8, outputIm(3:3:end, 2:3:end), 8, I_subimages);
I_subimages{8} = I8; 
I9 = decompression_hdl(encoded_bitstream9, height9, width9, outputIm(3:3:end, 3:3:end), 9, I_subimages);
I_subimages{9} = I9; 
I_psd = combine_subimages(I1, I2, I3, I4, I5, I6, I7, I8, I9, ActivePixels, ActiveLines);

if decompression_mode == 1
    I_reconstruct = PSD_decompress(I_psd);
    I_reconstruct = iterative_filter(I_reconstruct, 'FGS');
else
    I_reconstruct = MRF_decompression(I_psd);
end
figure;
imshow(I_reconstruct, [0, 255], 'InitialMagnification', 500);
title('Decompressed Image');

psnr_val = psnr(uint8(I_reconstruct), uint8(inputIm), 255);
ssim_val = ssim(uint8(I_reconstruct), uint8(inputIm));
disp(['compression ratio = ', num2str(compression_ratio)]);
disp(['psnr = ', num2str(psnr_val)]);
disp(['ssim = ', num2str(ssim_val)]);

end


function encoded_bitstream = bitstream_store(encoded_bitstream, bitstream, bitstream_length, bitstream_index)
bitstream = dec2bin(bitstream);
if bitstream_length ~= length(bitstream)
    bitstream_index = bitstream_index + 1;
    encoded_bitstream(bitstream_index+1) = '0';
end

for i = 1:length(bitstream)
    encoded_bitstream(bitstream_index+i) = bitstream(i);
end
end
