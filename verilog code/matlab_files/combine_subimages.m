function I_psd = combine_subimages(I1,I2,I3,I4,I5,I6,I7,I8,I9,width,height)

I_psd = zeros(height,width);
microshift_x = 0;
microshift_y = 0;
for x = 1:size(I1,1)
    for y = 1:size(I1,2)
        I_psd((x-1)*3+1 ,(y-1)*3+1) = I1(x,y);
    end
end

for x = 1:size(I2,1)
    for y = 1:size(I2,2)
        I_psd((x-1)*3+1 ,(y-1)*3+2) = I2(x,y);
    end
end

for x = 1:size(I3,1)
    for y = 1:size(I3,2)
        I_psd((x-1)*3+1 ,(y-1)*3+3) = I3(x,y);
    end
end

for x = 1:size(I4,1)
    for y = 1:size(I4,2)
        I_psd((x-1)*3+2 ,(y-1)*3+3) = I4(x,y);
    end
end

for x = 1:size(I5,1)
    for y = 1:size(I5,2)
        I_psd((x-1)*3+2 ,(y-1)*3+2) = I5(x,y);
    end
end

for x = 1:size(I6,1)
    for y = 1:size(I6,2)
        I_psd((x-1)*3+2 ,(y-1)*3+1) = I6(x,y);
    end
end

for x = 1:size(I7,1)
    for y = 1:size(I7,2)
        I_psd((x-1)*3+3 ,(y-1)*3+1) = I7(x,y);
    end
end

for x = 1:size(I8,1)
    for y = 1:size(I8,2)
        I_psd((x-1)*3+3 ,(y-1)*3+2) = I8(x,y);
    end
end

for x = 1:size(I9,1)
    for y = 1:size(I9,2)
        I_psd((x-1)*3+3 ,(y-1)*3+3) = I9(x,y);
    end
end

figure;imshow(I_psd,[0,255],'InitialMagnification',1000);
title('Combined subimages');



