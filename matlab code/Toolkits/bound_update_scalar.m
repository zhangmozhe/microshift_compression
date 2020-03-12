function [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, x, shift)

ub_temp = x + int16(32) - shift;
lb_temp = x - shift;
if ub_temp >= lowerbound && lb_temp <= upperbound
    if ub_temp < upperbound
        upperbound = ub_temp;
    end
    if lb_temp > lowerbound
        lowerbound = lb_temp;
    end
end
