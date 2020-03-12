function error_modulo = ModRange(error_value,range)
% % error residual alphabet
% % range = 8: map to [-4,3]
% % range = 4: map to [-2,1]
% % range = 2: map to [-1,0]

if (error_value < ceil(-range/2))
    error_modulo = error_value + range;
else
    if (error_value > ceil(range/2-1))
        error_modulo = error_value - range;
    else
        error_modulo = error_value;
    end
end



