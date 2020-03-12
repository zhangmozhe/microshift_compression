function ImageData_generation(image_name, ActivePixels, ActiveLines)
if nargin < 1
    %image_name = 'input_images/Boats.bmp';
    image_name = 'rice.png';
    ActivePixels = 216; % 64
    ActiveLines = 256; % 48
end
origIm = imread(image_name);

if ndims(origIm) == 3
    origIm = rgb2gray(origIm);
end
[height,width] = size(origIm);
origIm = imresize(origIm,[ActiveLines,ActivePixels]);
origImSize = size(origIm);
inputIm = origIm(1:ActiveLines,1:ActivePixels);
figure;imshow(inputIm,'InitialMagnification',1000);
title('Input Image');
disp(['generating image data for the image: ', image_name])

%% output image data to the file
fileID = fopen('image.dat','w');
fileID1 = fopen('hdlsrc/image.dat','w');
fileID2 = fopen('post_synthesis/image.dat','w');
fileID3 = fopen('post_layout/image.dat','w');
I_scan = inputIm';
I_scan = I_scan(:);
for i = 1:length(I_scan)
    fprintf(fileID,'%x\n',I_scan(i));
    fprintf(fileID1,'%x\n',I_scan(i));
    fprintf(fileID2,'%x\n',I_scan(i));
    fprintf(fileID3,'%x\n',I_scan(i));
end
fclose(fileID);
fclose(fileID1);
fclose(fileID2);
fclose(fileID3);