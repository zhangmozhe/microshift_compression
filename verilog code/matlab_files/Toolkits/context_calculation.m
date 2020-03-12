function [a,b,c,d,e] = context_calculation(image, width, index)
%    c  a  d
% e  b  x

persistent b_LastLine;
if isempty(b_LastLine)
   b_LastLine = 0;
end

if(index <= width) % if on the first row of the image
    if(mod(index,width) == 1) % if also on first col
        a = 0; b = 0; c = 0; d = 0; e = 0;
        b_LastLine = 0;   % update saved 'a'
    else
        b = image(index - 1); a = b; c = b; d = b; 
        if (mod(index,width) == 2)
            e = 0;
        else
            e = image(index - 2);
        end
    end
else
    if(mod(index,width) == 1)       % if on the first col but not the first row
        a = image(index - width);
        b = a;
        c = b_LastLine;      
        d = image((index - width) + 1);
        e = b;
        b_LastLine = b;
    elseif(mod(index,width) == 2)   % if on the second col but not the first row
        a = image(index - width);
        b = image(index - 1);
        c = image((index - width) - 1);     
        d = image((index - width) + 1);
        e = b_LastLine;
    elseif(mod(index,width) == 0)   % if on the last col but not the first row
        a = image(index - width);
        b = image(index - 1);
        c = image((index - width) - 1);
        d = a;
        e = image(index - 2);
    else                            % otherwise
        a = image(index - width);
        b = image(index - 1);
        c = image((index - width) - 1);
        d = image((index - width) + 1);
        e = image(index - 2);
    end
end