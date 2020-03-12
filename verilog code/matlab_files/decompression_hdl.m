function I_recover1 = decompression_hdl(encoded_bitstream,height,width,I_truth,subimage_index,I_subimages)

pixel_index = 1;     % point to the pixel to be processed
bitstream_index = 1; % point to the next bit
bitstream_length = length(encoded_bitstream);
I_recover = zeros(height*width,1);
range = 8;
I_truth_vector = I_truth';
I_truth_vector = I_truth_vector(:);
residue_learned = load('residue_learned1.mat');
residue_learned = int(residue_learned.residue_learned1);

mode = 0;
while (bitstream_index <= bitstream_length)
    if (mode == 0)
        % context calculation
        [a,b,c,d,e] = context_calculation_zeropad(I_recover, width, pixel_index);
        xx = ceil(pixel_index/width);
        yy = mod(pixel_index,width);
        if yy == 0
            yy = width;
        end
        g1 = a - c; g2 = c - b; g3 = d - a; g4 = b - e;
        
        upperbound = 255;
        lowerbound = 0;
        switch subimage_index
            case 1
                gq1 = double(g_quantize(g1));
                gq2 = double(g_quantize(g2));
                gq3 = double(g_quantize(g3));
                gq4 = double(g_quantize(g4));
                context_index = gq1*5^3 + gq2*5^2 + gq3*5^1 + gq4 + 1;
                residue = residue_learned(context_index);
                if residue == int8(8)
                    if(c >= max(b,a))
                        predict_x = min(b,a);
                    elseif(c <= min(b,a))
                        predict_x = max(b,a);
                    else
                        predict_x = b + a - c;
                    end
                else
                    predict_x = b + residue;
                    if predict_x < 0
                        predict_x = 0;
                    end
                    if predict_x > 7
                        predict_x = 7;
                    end
                end
            case 2 % inter-prediction
                neighbor1 = subimage_access(I_subimages{1},xx,yy);
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor1, int16(0));
                predict_x0 = floor((double(upperbound) + double(lowerbound))/2) + int16(-4);
%                 predict_x0 = bitsra((upperbound + lowerbound),1) + int16(4);
                predict_x0 = uint8(predict_x0);
%                 predict_x = int8(bitsrl(predict_x0, 5));
                predict_x = int8(floor(double(predict_x0)/32));
            case 3
                neighbor1 = subimage_access(I_subimages{1},xx,yy+1);
                neighbor2 = subimage_access(I_subimages{2},xx,yy);
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor1, int16(0));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor2, int16(-4));
                predict_x0 = floor((double(upperbound) + double(lowerbound))/2) + int16(-7);
%                 predict_x0 = bitsra((upperbound + lowerbound),1) + int16(7);
                predict_x0 = uint8(predict_x0);
%                 predict_x = int8(bitsrl(predict_x0, 5));
                predict_x = int8(floor(double(predict_x0)/32));
            case 4
                neighbor1 = subimage_access(I_subimages{1},xx,yy+1);
                neighbor2 = subimage_access(I_subimages{2},xx,yy);
                neighbor3 = subimage_access(I_subimages{3},xx,yy);
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor1, int16(0));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor2, int16(-4));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor3, int16(-7));
                predict_x0 = floor((double(upperbound) + double(lowerbound))/2) + int16(-11);
%                 predict_x0 = bitsra((upperbound + lowerbound),1) + int16(11);
                predict_x0 = uint8(predict_x0);
%                 predict_x = int8(bitsrl(predict_x0, 5));
                predict_x = int8(floor(double(predict_x0)/32));
            case 5
                neighbor1 = subimage_access(I_subimages{1},xx,yy);
                neighbor2 = subimage_access(I_subimages{2},xx,yy);
                neighbor3 = subimage_access(I_subimages{3},xx,yy);
                neighbor4 = subimage_access(I_subimages{4},xx,yy);
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor1, int16(0));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor2, int16(-4));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor3, int16(-7));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor4, int16(-11));
                predict_x0 = floor((double(upperbound) + double(lowerbound))/2) + int16(-14);
%                 predict_x0 = bitsra((upperbound + lowerbound),1) + int16(14);
                predict_x0 = uint8(predict_x0);
%                 predict_x = int8(bitsrl(predict_x0, 5));
                predict_x = int8(floor(double(predict_x0)/32));
            case 6
                neighbor1 = subimage_access(I_subimages{1},xx,yy);
                neighbor2 = subimage_access(I_subimages{2},xx,yy);
                neighbor3 = subimage_access(I_subimages{3},xx,yy-1);
                neighbor4 = subimage_access(I_subimages{4},xx,yy-1);
                neighbor5 = subimage_access(I_subimages{5},xx,yy);
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor1, int16(0));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor2, int16(-4));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor3, int16(-7));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor4, int16(-11));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor5, int16(-14));
                predict_x0 = floor((double(upperbound) + double(lowerbound))/2) + int16(-18);
%                 predict_x0 = bitsra((upperbound + lowerbound),1) + int16(18);
                predict_x0 = uint8(predict_x0);
%                 predict_x = int8(bitsrl(predict_x0, 5));
                predict_x = int8(floor(double(predict_x0)/32));
            case 7
                neighbor1 = subimage_access(I_subimages{1},xx,yy);
                neighbor2 = subimage_access(I_subimages{2},xx,yy);
                neighbor3 = subimage_access(I_subimages{3},xx,yy-1);
                neighbor4 = subimage_access(I_subimages{4},xx,yy-1);
                neighbor5 = subimage_access(I_subimages{5},xx,yy);
                neighbor6 = subimage_access(I_subimages{6},xx,yy);
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor1, int16(0));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor2, int16(-4));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor3, int16(-7));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor4, int16(-11));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor5, int16(-14));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor6, int16(-18));
                predict_x0 = floor((double(upperbound) + double(lowerbound))/2) + int16(-21);
%                 predict_x0 = bitsra((upperbound + lowerbound),1) + int16(21);
                predict_x0 = uint8(predict_x0);
%                 predict_x = int8(bitsrl(predict_x0, 5));
                predict_x = int8(floor(double(predict_x0)/32));
            case 8
                neighbor1 = subimage_access(I_subimages{1},xx,yy);
                neighbor2 = subimage_access(I_subimages{2},xx,yy);
                neighbor3 = subimage_access(I_subimages{3},xx,yy);
                neighbor4 = subimage_access(I_subimages{4},xx,yy);
                neighbor5 = subimage_access(I_subimages{5},xx,yy);
                neighbor6 = subimage_access(I_subimages{6},xx,yy);
                neighbor7 = subimage_access(I_subimages{7},xx,yy);
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor1, int16(0));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor2, int16(-4));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor3, int16(-7));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor4, int16(-11));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor5, int16(-14));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor6, int16(-18));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor7, int16(-21));
                predict_x0 = floor((double(upperbound) + double(lowerbound))/2) + int16(-25);
%                 predict_x0 = bitsra((upperbound + lowerbound),1) + int16(25);
                predict_x0 = uint8(predict_x0);
%                 predict_x = int8(bitsrl(predict_x0, 5));
                predict_x = int8(floor(double(predict_x0)/32));
            case 9
                neighbor1 = subimage_access(I_subimages{1},xx,yy+1);
                neighbor2 = subimage_access(I_subimages{2},xx,yy);
                neighbor3 = subimage_access(I_subimages{3},xx,yy);
                neighbor4 = subimage_access(I_subimages{4},xx,yy);
                neighbor5 = subimage_access(I_subimages{5},xx,yy);
                neighbor6 = subimage_access(I_subimages{6},xx,yy+1);
                neighbor7 = subimage_access(I_subimages{7},xx,yy+1);
                neighbor8 = subimage_access(I_subimages{8},xx,yy);
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor1, int16(0));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor2, int16(-4));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor3, int16(-7));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor4, int16(-11));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor5, int16(-14));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor6, int16(-18));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor7, int16(-21));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor8, int16(-25));
                predict_x0 = floor((double(upperbound) + double(lowerbound))/2) + int16(-28);
%                 predict_x0 = bitsra((upperbound + lowerbound),1) + int16(28);
                predict_x0 = uint8(predict_x0);
%                 predict_x = int8(bitsrl(predict_x0, 5));
                predict_x = int8(floor(double(predict_x0)/32));
        end
                
        if (xx==1 && yy>1)
            predict_x = e;
        end
        
        % compute gradients 
        if(g1 == g2 && g1 == g3 && g1 == g4 && g1 == 0 && pixel_index > 1)  % if uniform patch && not first pixel
            mode = 1;                        % go to runlength mode
            run_value = b;
        end
    end
    
    % predictive mode
    if (mode == 0)
        % step out and decode Golomb code
        error_value = 0;
        while(encoded_bitstream(bitstream_index) == '1')
            error_value = error_value + 1;
            bitstream_index = bitstream_index + 1;
            if bitstream_index > bitstream_length
                break;
            end
        end
        bitstream_index = bitstream_index + 1;
        
        % map back error
        error_value_mapped = remap(error_value, predict_x, range);
        x = error_value_mapped + predict_x;
        
        I_recover(pixel_index) = x;
        pixel_index = pixel_index + 1;
    end
    
    % runlength mode
    if (mode == 1)        
        % distance to the end of line
        width1 = mod(pixel_index,width);
        if (width1 == 0)
            width1 = width;
        end
        max_length = width - width1 + 1;
        
        % step out runlength code
        run_count = 0;
        while(encoded_bitstream(bitstream_index) == '1')
            run_count = run_count + 1;
            bitstream_index = bitstream_index + 1;
            if bitstream_index > bitstream_length
                break;
            end
        end
        bitstream_index = bitstream_index + 1;
        
        % assign run values
        for i = 1:run_count
            I_recover(pixel_index) = run_value;
            pixel_index = pixel_index + 1;
        end
        
        % check EOL
        if (run_count >= max_length)
            EOL = 1;
        else
            EOL = 0;
        end
        
        % step out runvalue code (whether EOL)
        if (~EOL)
            [a,b] = context_calculation_zeropad(I_recover, width, pixel_index);
            if (b==a)
                run_interrupt_type = 1;
            else
                run_interrupt_type = 0;
            end
            predict_x = a;
        
            run_error_value_mapped = 0;
            while(encoded_bitstream(bitstream_index) == '1')
                run_error_value_mapped = run_error_value_mapped + 1;
                bitstream_index = bitstream_index + 1;
                if bitstream_index > bitstream_length
                    break;
                end
            end
            bitstream_index = bitstream_index + 1;
            
            % map back runvalue error
            run_error_value = remap(run_error_value_mapped + run_interrupt_type, predict_x, range);
            %if((run_interrupt_type == 0) && (b>a))
            %run_error_value = -run_error_value;
            %end
            interrupt_value = run_error_value + predict_x;
            
            % assign interrupt value
            I_recover(pixel_index) = interrupt_value;
            pixel_index = pixel_index + 1;
        end
        
        % return to predictive mode
        mode = 0; 
    end
    
end %end of while loop

I_recover1 = reshape(I_recover, [width, height])' * 32;
% for debugging
disp(['finish the decompression of the subimage: ', num2str(subimage_index)])
% figure;imshow(abs(double(I_recover1)-double(I_truth)),[0,32]);
end

function value = subimage_access(subimage,x,y)
[height,width] = size(subimage);
if x==0 || y == 0 || x>height || y>width
    value = 0;
else
    value = subimage(x,y);
end
end
% 
% function out = bitsrl(in, k)
% out = int16(in*2^k);
% end
% 
% function out = bitsra(in, k)
% out = in*2^(-k);
% end


