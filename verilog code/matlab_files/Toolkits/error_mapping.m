function mapped_error_value = error_mapping(error_value,predict_x,range)

% % error residual alphabet
% % bitnum = 8: map to [-4,3]
% % bitnum = 4: map to [-2,1]
% % bitnum = 2: map to [-1,0]
% error_value = error(index);
% if (error_value < ceil(-range/2))
%     error_value = error_value + range;
% end
% if (error_value > ceil(range/2-1))
%     error_value = error_value - range;
% end
%
% % map reduced error residual to non negative number
% if error_value >= 0
%     mapped_error_value = 2 * error_value;
% else
%     mapped_error_value = (-2) * error_value - 1;
% end

% map the residual

if (predict_x < range/2)
    position = 1; % left
else
    position = 2; % right
end
lower_error = -predict_x;
upper_error = range - predict_x - 1;
if (error_value == 0)
    mapped_error_value = 0;
else
    if (position == 1) % left
        % mapped to [0, -1, 1, -2, 2, ...]
        if error_value >= 0
            mapped_error_value = min(error_value - 1, -lower_error) + error_value;
        else
            mapped_error_value = min(-error_value, upper_error) + (-error_value);
        end
    else
        % mapped to [0, 1, -1, 2, -2, ...]
        if error_value >= 0 % right
            mapped_error_value = min(error_value, -lower_error) + error_value;
        else
            mapped_error_value = min(-error_value - 1, upper_error) + (-error_value);
        end
    end
end