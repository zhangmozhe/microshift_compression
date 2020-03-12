function error_value = ModRange_reverse(predict_x, error_modulo, range)

error_lower_bound = 0 - predict_x;
error_upper_bound = range - 1 - predict_x;

if (error_modulo > error_upper_bound)
    error_value = error_modulo - range;
elseif (error_modulo < error_lower_bound)
    error_value = error_modulo + range;
else
    error_value = error_modulo;
end
