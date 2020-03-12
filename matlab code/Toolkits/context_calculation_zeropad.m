function [a, b, c, d, e] = context_calculation_zeropad(image, width, index)
%    c  a  d
% e  b  x

if (index <= width) % if on the first row of the image
    if (mod(index, width) == 1) % if also on first col
        a = 0;
        b = 0;
        c = 0;
        d = 0;
        e = 0;
    else
        b = image(index-1);
        a = 0;
        c = 0;
        d = 0;
        if (mod(index, width) == 2)
            e = 0;
        else
            e = image(index-2);
        end
    end
else
    if (mod(index, width) == 1) % if on the first col but not the first row
        a = image(index-width);
        b = 0;
        c = 0;
        d = image((index - width)+1);
        e = 0;
    elseif (mod(index, width) == 2) % if on the second col but not the first row
        a = image(index-width);
        b = image(index-1);
        c = image((index - width)-1);
        d = image((index - width)+1);
        e = 0;
    elseif (mod(index, width) == 0) % if on the last col but not the first row
        a = image(index-width);
        b = image(index-1);
        c = image((index - width)-1);
        d = 0;
        e = image(index-2);
    else % otherwise
        a = image(index-width);
        b = image(index-1);
        c = image((index - width)-1);
        d = image((index - width)+1);
        e = image(index-2);
    end
end