close all;
addpath('matlab_files/');
addpath('matlab_files/Toolkits/');

%% prepare the image data
ActivePixels = 216; % 64
ActiveLines = 256; % 48
image_name = 'input_images/churchandcapitol.bmp';
ImageData_generation(image_name, ActivePixels, ActiveLines)

%% modelsim simulation
GUI_mode = false;
cd hdlsrc
delete subimage*.dat
% delete work
disp('starting the Modelsim simulation');
if GUI_mode
    [status,cmdout] = system('vsim -gui -do ../script/my_testbench_pre_synthesis.do','-echo');
else
    [status,cmdout] = system('vsim -c -do ../script/my_testbench_pre_synthesis_nowave.do','-echo');
end
disp('Modelsim simulation finished');
cd ..

%% decompression
disp('starting the decompression')
test_decompress('hdlsrc/')