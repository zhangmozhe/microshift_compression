function test_decompress(directory)
% addpath('matlab_files/');
% addpath('matlab_files/Toolkits/');

width = 216;
height = 256;
frame_num = 1;

% choose the directory for pre-synthesis, post-synthesis and post-layout
% simulations
if nargin < 1
    directory = 'hdlsrc/';
    %directory = 'post_synthesis/';
    %directory = 'post_layout/';
end

numPixelsPerFrame = width*height;
encoded_bitstream1 = repmat(char(0),1,numPixelsPerFrame*8);
encoded_bitstream2 = repmat(char(0),1,numPixelsPerFrame*8);
encoded_bitstream3 = repmat(char(0),1,numPixelsPerFrame*8);
encoded_bitstream4 = repmat(char(0),1,numPixelsPerFrame*8);
encoded_bitstream5 = repmat(char(0),1,numPixelsPerFrame*8);
encoded_bitstream6 = repmat(char(0),1,numPixelsPerFrame*8);
encoded_bitstream7 = repmat(char(0),1,numPixelsPerFrame*8);
encoded_bitstream8 = repmat(char(0),1,numPixelsPerFrame*8);
encoded_bitstream9 = repmat(char(0),1,numPixelsPerFrame*8);
bitstream_index1 = 0;
bitstream_index2 = 0;
bitstream_index3 = 0;
bitstream_index4 = 0;
bitstream_index5 = 0;
bitstream_index6 = 0;
bitstream_index7 = 0;
bitstream_index8 = 0;
bitstream_index9 = 0;

bitstream_raw = read_raw([directory,'fp_bitstream.dat']);
bitstream_index_raw = read_raw([directory,'fp_bitstream_index.dat']);
bitstream_length_raw = read_raw([directory,'fp_bitstream_length.dat']);

for i = 1:length(bitstream_raw)
    bitstream = bitstream_raw(i);
    bitstream_length = bitstream_length_raw(i);
    switch bitstream_index_raw(i)
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
            disp('error')
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


width_mod = mod(width,3);
height_mod = mod(height,3);
switch width_mod
    case 0
        col1_more = 0; col2_more = 0; col3_more = 0;
    case 1
        col1_more = 1; col2_more = 0; col3_more = 0;
    case 2
        col1_more = 1; col2_more = 1; col3_more = 0;
end
switch height_mod
    case 0
        row1_more = 0; row2_more = 0; row3_more = 0;
    case 1
        row1_more = 1; row2_more = 0; row3_more = 0;
    case 2
        row1_more = 1; row2_more = 1; row3_more = 0;
end
width1 = floor(width/3) + col1_more; height1 = floor(height/3) + row1_more;
width2 = floor(width/3) + col2_more; height2 = floor(height/3) + row1_more;
width3 = floor(width/3) + col3_more; height3 = floor(height/3) + row1_more;
width4 = floor(width/3) + col3_more; height4 = floor(height/3) + row2_more;
width5 = floor(width/3) + col2_more; height5 = floor(height/3) + row2_more;
width6 = floor(width/3) + col1_more; height6 = floor(height/3) + row2_more;
width7 = floor(width/3) + col1_more; height7 = floor(height/3) + row3_more;
width8 = floor(width/3) + col2_more; height8 = floor(height/3) + row3_more;
width9 = floor(width/3) + col3_more; height9 = floor(height/3) + row3_more;

I_subimages = cell(9,1);
outputIm = zeros(height,width);
I1 = decompression_hdl(encoded_bitstream1,height1,width1,outputIm(1:3:end,1:3:end),1,I_subimages);I_subimages{1} = I1;%figure;imshow(I1,[0,255]);
I2 = decompression_hdl(encoded_bitstream2,height2,width2,outputIm(1:3:end,2:3:end),2,I_subimages);I_subimages{2} = I2;%figure;imshow(I2,[0,255]);
I3 = decompression_hdl(encoded_bitstream3,height3,width3,outputIm(1:3:end,3:3:end),3,I_subimages);I_subimages{3} = I3;%figure;imshow(I3,[0,255]);
I4 = decompression_hdl(encoded_bitstream4,height4,width4,outputIm(2:3:end,1:3:end),4,I_subimages);I_subimages{4} = I4;%figure;imshow(I4,[0,255]);
I5 = decompression_hdl(encoded_bitstream5,height5,width5,outputIm(2:3:end,2:3:end),5,I_subimages);I_subimages{5} = I5;%figure;imshow(I5,[0,255]);
I6 = decompression_hdl(encoded_bitstream6,height6,width6,outputIm(2:3:end,3:3:end),6,I_subimages);I_subimages{6} = I6;%figure;imshow(I6,[0,255]);
I7 = decompression_hdl(encoded_bitstream7,height7,width7,outputIm(3:3:end,1:3:end),7,I_subimages);I_subimages{7} = I7;%figure;imshow(I7,[0,255]);
I8 = decompression_hdl(encoded_bitstream8,height8,width8,outputIm(3:3:end,2:3:end),8,I_subimages);I_subimages{8} = I8;%figure;imshow(I8,[0,255]);
I9 = decompression_hdl(encoded_bitstream9,height9,width9,outputIm(3:3:end,3:3:end),9,I_subimages);I_subimages{9} = I9;%figure;imshow(I9,[0,255]);

I_psd = combine_subimages(I1,I2,I3,I4,I5,I6,I7,I8,I9,width,height);
I_reconstruct = PSD_decompress(I_psd, 'negative');
I_reconstruct_filter = I_reconstruct;
ITER_NUM = 5;
for j = 1: ITER_NUM
    %     I_reconstruct_filter = imguidedfilter( I_reconstruct_filter, 'DegreeOfSmoothing', 1.2, 'NeighborhoodSize',[11 11]);
    I_reconstruct_filter = fastguidedfilter(I_reconstruct_filter, I_reconstruct_filter, 11, 2^2, 1);
end
figure;imshow(I_reconstruct,[0,255],'InitialMagnification',1000);
title('Decomrpessed Image');
figure;imshow(I_reconstruct_filter,[0,255],'InitialMagnification',1000);
title('Decomrpessed Image with filtering');

end


function encoded_bitstream = bitstream_store(encoded_bitstream, bitstream, bitstream_length, bitstream_index)
bitstream = dec2bin(bitstream);
if bitstream_length~= length(bitstream)
    bitstream_index = bitstream_index + 1;
    encoded_bitstream(bitstream_index+1) = '0';
end

for i = 1:length(bitstream)
    encoded_bitstream(bitstream_index+i) = bitstream(i);
end
end




