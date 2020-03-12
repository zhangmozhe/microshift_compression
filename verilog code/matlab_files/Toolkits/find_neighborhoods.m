function [neighborhoods, shifts] = find_neighborhoods(I_subimages, pixel_index, subimage_index, width, height, use_causal_lines)

shifts = zeros(subimage_index - 1, 1);
neighborhoods = zeros(subimage_index - 1, 1);
I1 = I_subimages{1};
I2 = I_subimages{2};
I3 = I_subimages{3};
I4 = I_subimages{4};
I5 = I_subimages{5};
I6 = I_subimages{6};
I7 = I_subimages{7};
I8 = I_subimages{8};
I9 = I_subimages{9};

x = ceil(pixel_index/width);
y = mod(pixel_index,width);
if y == 0
    y = width;
end

if use_causal_lines
    switch subimage_index
        case 2
            neighborhoods(1) = I1(x,y);
        case 3
            if y == width
                neighborhoods(1) = I1(x,width);
            else
                neighborhoods(1) = I1(x,y+1);
            end
            neighborhoods(2) = I2(x,y);
        case 4
            if y == width
                neighborhoods(1) = I1(x,width);
            else
                neighborhoods(1) = I1(x,y+1);
            end
            neighborhoods(2) = I2(x,y);
            neighborhoods(3) = I3(x,y);
        case 5
            neighborhoods(1) = I1(x,y);
            neighborhoods(2) = I2(x,y);
            neighborhoods(3) = I3(x,y);
            neighborhoods(4) = I4(x,y);
        case 6
            neighborhoods(1) = I1(x,y);
            neighborhoods(2) = I2(x,y);
            if y == 1
                neighborhoods(3) = I3(x,1);
                neighborhoods(4) = I4(x,1);
            else
                neighborhoods(3) = I3(x,y-1);
                neighborhoods(4) = I4(x,y-1);
            end
            neighborhoods(5) = I5(x,y);
        case 7
            neighborhoods(1) = I1(x,y);
            neighborhoods(2) = I2(x,y);
            if y == 1
                neighborhoods(3) = I3(x,1);
                neighborhoods(4) = I4(x,1);
            else
                neighborhoods(3) = I3(x,y-1);
                neighborhoods(4) = I4(x,y-1);
            end
            neighborhoods(5) = I5(x,y);
            neighborhoods(6) = I6(x,y);
        case 8
            neighborhoods(1) = I1(x,y);
            neighborhoods(2) = I2(x,y);
            neighborhoods(3) = I3(x,y);
            neighborhoods(4) = I4(x,y);
            neighborhoods(5) = I5(x,y);
            neighborhoods(6) = I6(x,y);
            neighborhoods(7) = I7(x,y);
        case 9
            neighborhoods(2) = I2(x,y);
            neighborhoods(3) = I3(x,y);
            neighborhoods(4) = I4(x,y);
            neighborhoods(5) = I5(x,y);
            neighborhoods(8) = I8(x,y);
            if y == width
                neighborhoods(1) = I1(x,width);
                neighborhoods(6) = I6(x,width);
                neighborhoods(7) = I7(x,width);
            else
                neighborhoods(1) = I1(x,y+1);
                neighborhoods(6) = I6(x,y+1);
                neighborhoods(7) = I7(x,y+1);
            end
            
    end
else
    switch subimage_index
        case 2
            neighborhoods(1) = I1(x,y);
        case 3
            if y == width
                neighborhoods(1) = I1(x,width);
            else
                neighborhoods(1) = I1(x,y+1);
            end
            neighborhoods(2) = I2(x,y);
        case 4
            if y == width
                neighborhoods(1) = I1(x,width);
            else
                neighborhoods(1) = I1(x,y+1);
            end
            neighborhoods(2) = I2(x,y);
            neighborhoods(3) = I3(x,y);
        case 5
            neighborhoods(1) = I1(x,y);
            neighborhoods(2) = I2(x,y);
            neighborhoods(3) = I3(x,y);
            neighborhoods(4) = I4(x,y);
        case 6
            neighborhoods(1) = I1(x,y);
            neighborhoods(2) = I2(x,y);
            if y == 1
                neighborhoods(3) = I3(x,1);
                neighborhoods(4) = I4(x,1);
            else
                neighborhoods(3) = I3(x,y-1);
                neighborhoods(4) = I4(x,y-1);
            end
            neighborhoods(5) = I5(x,y);
        case 7
            if x == height
                neighborhoods(1) = I1(height,y);
                neighborhoods(2) = I2(height,y);
                if y == 1
                    neighborhoods(3) = I3(height,1);
                else
                    neighborhoods(3) = I3(height,y-1);
                end
            else
                neighborhoods(1) = I1(x+1,y);
                neighborhoods(2) = I2(x+1,y);
                if y == 1
                    neighborhoods(3) = I3(x+1,1);
                else
                    neighborhoods(3) = I3(x+1,y-1);
                end
            end
            if y == 1
                neighborhoods(4) = I4(x,1);
            else
                neighborhoods(4) = I4(x,y-1);
            end
            neighborhoods(5) = I5(x,y);
            neighborhoods(6) = I6(x,y);
        case 8
            if x == height
                neighborhoods(1) = I1(height,y);
                neighborhoods(2) = I2(height,y);
                neighborhoods(3) = I3(height,y);
            else
                neighborhoods(1) = I1(x+1,y);
                neighborhoods(2) = I2(x+1,y);
                neighborhoods(3) = I3(x+1,y);
            end
            neighborhoods(4) = I4(x,y);
            neighborhoods(5) = I5(x,y);
            neighborhoods(6) = I6(x,y);
            neighborhoods(7) = I7(x,y);
        case 9
            if x == height
                if y == width
                    neighborhoods(1) = I1(height,width);
                else
                    neighborhoods(1) = I1(height,y+1);
                end
            else
                if y == width
                    neighborhoods(1) = I1(x+1,width);
                else
                    neighborhoods(1) = I1(x+1,y+1);
                end
            end
            
            if x == height
                neighborhoods(2) = I2(height,y);
                neighborhoods(3) = I3(height,y);
            else
                neighborhoods(2) = I2(x+1,y);
                neighborhoods(3) = I3(x+1,y);
            end
            neighborhoods(4) = I4(x,y);
            neighborhoods(5) = I5(x,y);
            if y == width
                neighborhoods(6) = I6(x,width);
                neighborhoods(7) = I7(x,width);
            else
                neighborhoods(6) = I6(x,y+1);
                neighborhoods(7) = I7(x,y+1);
            end
            neighborhoods(8) = I8(x,y);
    end
end




