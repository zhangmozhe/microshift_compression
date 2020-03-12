function I_reconstruct = PSD_decompress(I_quant)

bitnum = 3;
pattern_num = 3;
pattern_norm = [0, 1, 2, 5, 4, 3, 6, 7, 8];

thresh = [1:(2^bitnum - 1)] * (256 / 2^bitnum) - 1;
pattern_size = pattern_num;
L = pattern_size * pattern_size;
w = 256 / (2^bitnum); % quantization error
pattern_norm = reshape(pattern_norm, [pattern_size, pattern_size])';
[height, width] = size(I_quant);
distortion_pad = pattern(pattern_size, height, width, w, pattern_norm) * (-1); % negative distortion pattern
pad_num = pattern_size - 2;

pattern_hsize = floor(pattern_num/2);
I_quantization = I_quant;
I_reconstruct = zeros(height, width);

for i = 1:height
    for j = 1:width %loop for every pixel
        if i == 1
            patch_start_x = 1;
        else
            patch_start_x = i - pattern_hsize;
        end
        if j == 1
            patch_start_y = 1;
        else
            patch_start_y = j - pattern_hsize;
        end
        if i == height
            patch_end_x = height;
        else
            patch_end_x = i + pattern_hsize;
        end
        if j == width
            patch_end_y = width;
        else
            patch_end_y = j + pattern_hsize;
        end

        Neighbour_tmp = I_quantization(patch_start_x:patch_end_x, patch_start_y:patch_end_y);
        Neighbour = Neighbour_tmp(:);
        distortion_pattern_array_tmp = distortion_pad(patch_start_x:patch_end_x, patch_start_y:patch_end_y);
        distortion_pattern_array = distortion_pattern_array_tmp(:);

        ub = I_quantization(i, j) + w - distortion_pad(i, j);
        lb = I_quantization(i, j) - distortion_pad(i, j);
        ub_array = Neighbour + w - distortion_pattern_array;
        lb_array = Neighbour - distortion_pattern_array;

        for k = 1:length(Neighbour)
            ub_temp = ub_array(k);
            lb_temp = lb_array(k);
            if ub_temp >= lb && lb_temp <= ub
                if ub_temp < ub
                    ub = ub_temp;
                end
                if lb_temp > lb
                    lb = lb_temp;
                end
            end
        end
        I_reconstruct(i, j) = (ub + lb) / 2;
    end
end


