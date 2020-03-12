function I_decompression = MRF_decompression(I, option)
if nargin < 1
    addpath('Toolkits');
    addpath(genpath('.\Toolkits\gco-v3.0'));
    image_dir = 'input_images\';
    image_name = 'elaine';
    image_type = '.bmp';
    I = imread([image_dir, image_name, image_type]);
end
if ndims(I) == 3
    I = rgb2gray(I);
end

if nargin < 2
    modulo = 1;
    figure_on = 1;
    bitnum = 3;
end

%% parameters
% a good parameter setting
% gamma = 14; sigma = 8; Vmax = 128; p = 1; beta = 0; alpha = 0.06; T = 64

subimage_index = 9; % subimage index
switch subimage_index
    case 1
        gamma = 12 / 9 * 1;
        sigma = 8;
    case 2
        gamma = 12 / 9 * 2;
        sigma = 8;
    case 3
        gamma = 12 / 9 * 3;
        sigma = 8;
    case 4
        gamma = 12 / 9 * 4;
        sigma = 8;
    case 5
        gamma = 12 / 9 * 5;
        sigma = 8;
    case 6
        gamma = 12 / 9 * 6;
        sigma = 8;
    case 7
        gamma = 12 / 9 * 7;
        sigma = 8;
    case 8
        gamma = 12 / 9 * 8;
        sigma = 8;
    case 9
        gamma = 12 / 9 * 9;
        sigma = 8;
end
Vmax = 128;
p = 1;

%% PSD compression
pattern_size = 3;
pattern_norm = [0, 1, 2, 5, 4, 3, 6, 7, 8];
pattern_norm = reshape(pattern_norm, [pattern_size, pattern_size])'
w = 256 / (2^bitnum); % quantization error
[height, width] = size(I);

I_quant_pad = double(I);
I_reconstruct_fast = PSD_decompress(I_quant_pad);
distortion_pad = pattern(pattern_size, height, width, w, pattern_norm) * (-1);
distortion_pad(:, end) = [];
distortion_pad(:, end) = [];
distortion_pad(end, :) = [];
distortion_pad(end, :) = [];
[height, width] = size(I_quant_pad);

%% MRF decompression
z = I_quant_pad - distortion_pad;
z_vector = z(:);
z_clamp = z_vector;
z_clamp(z_clamp < 0) = 0;
unary = unary_energy_v1(z_vector, z_clamp, distortion_pad, subimage_index, w, sigma, true, modulo);
neighbors = mrf_neighbors(z, distortion_pad, gamma, true, modulo); % N_sites * N_sites
smoothcost = mrf_smoothness(p, Vmax); % N_labels * N_labels
z_init = uint8(I_reconstruct_fast);
z_init = z_init(:) + 1;

%% Graphcut
N_sites = length(z_vector);
N_labels = 256; % labels start from 1
h = GCO_Create(N_sites, N_labels); % Create new object with NumSites=4, NumLabels=3
% GCO_SetLabeling(h,z_clamp+1);
GCO_SetLabeling(h, z_init);
GCO_SetDataCost(h, unary);
GCO_SetNeighbors(h, neighbors);
GCO_SetSmoothCost(h, smoothcost);
GCO_SetVerbosity(h, 2);
GCO_SetLabelOrder(h, randperm(N_labels));
GCO_Expansion(h); % Compute optimal labeling via alpha-expansion
% GCO_Swap(h);
LabelResult = uint8(GCO_GetLabeling(h));
[Energy, DataCost, SmoothCost, LabelCost] = GCO_ComputeEnergy(h);
GCO_Delete(h); % Delete the GCoptimization object when finished

% resize and reshape result
mrf_result = reshape(LabelResult, [height, width]);
mrf_result = mrf_result - 1;
I_decompression = mrf_result;

%% visualization
if figure_on
    %     Energy
    %     DataCost
    %     SmoothCost
    %     LabelCost
    figure;
    subplot(1, 2, 1);
    imshow(mrf_result, [0, 255]);
    title('MRF decompression result');
    psnr_val = psnr(uint8(mrf_result), uint8(I), 255)
    ssim_val = ssim(uint8(mrf_result), uint8(I))
    psnr_val_fast = psnr(uint8(I_reconstruct_fast), uint8(I), 255)
    subplot(1, 2, 2);
    imshow(I_reconstruct_fast, [0, 255]);
    title('fast decompression result');
end
