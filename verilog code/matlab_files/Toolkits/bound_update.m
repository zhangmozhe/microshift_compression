function [upperbound, lowerbound] = bound_update(upperbound, lowerbound, I, shift)
% upperbound & lowerbound update for decompression
% upperbound array
% lowerbound arry
% I: subimage for updating bounds
% shift: shift value for the present subimage


[height, width] = size(I);
w = 32;
for x = 1:height
    for y = 1:width
        ub_temp = I(x,y) + w - shift;
        lb_temp = I(x,y) - shift;
        ub = upperbound(x,y) + w - shift;
        lb = lowerbound(x,y) - shift;
        if ub_temp >= lb && lb_temp <= ub
            if ub_temp < ub
                upperbound(x,y) = ub_temp;
            end
            if lb_temp > lb
                lowerbound(x,y) = lb_temp;
            end
        end
    end
end
end