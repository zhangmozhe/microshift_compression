function error_value_mapped = remap(error_value, predict_x, range) 
% for decompression
% for mapping back the error-value
if (predict_x < range/2)
    position = 1;
else
    position = 2;
end

lower_error = -predict_x;
upper_error = range - predict_x - 1;

if(error_value == 0)
    error_value_mapped = 0;
else
    if (position == 1)
        if (error_value <= 2*min(-lower_error, upper_error))
            if (mod(error_value,2) == 0)
                error_value_mapped = -ceil(error_value/2);
            else
                error_value_mapped = ceil(error_value/2);
            end
        else
            error_value_mapped = error_value - 2*min(-lower_error, upper_error) + min(-lower_error, upper_error);
        end
    else
       if (error_value <= 2*min(-lower_error, upper_error))
            if (mod(error_value,2) == 0)
                error_value_mapped = ceil(error_value/2);
            else
                error_value_mapped = -ceil(error_value/2);
            end
        else
            error_value_mapped = -(error_value - 2*min(-lower_error, upper_error) + min(-lower_error, upper_error));
        end
    end
end