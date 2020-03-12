function x_inter_prediction = inter_prediction(neighborhoods, shifts, image_index, use_causal_lines)
% inter-prediction

if use_causal_lines
    switch image_index
        case 2
            sequence = [1];
        case 3
            sequence = [1, 2];
        case 4
            sequence = [3, 1, 2]; %
        case 5
            sequence = [2, 4, 3, 1];
        case 6
            sequence = [1, 4, 5, 3, 2];
        case 7
            sequence = [6, 5, 4, 1, 3, 2];
        case 8
            sequence = [5, 7, 6, 4, 2, 3, 1];
        case 9
            sequence = [4, 7, 8, 5, 6, 3, 2, 1];
    end
else
    switch image_index
        case 2
            sequence = [1];
        case 3
            sequence = [2, 1];
        case 4
            sequence = [3, 2, 1];
        case 5
            sequence = [2, 4, 3, 1];
        case 6
            sequence = [1, 4, 5, 3, 2];
        case 7
            sequence = [6, 1, 4, 5, 3, 2];
        case 8
            sequence = [7, 5, 2, 6, 1, 4, 3];
        case 9
            sequence = [4, 8, 7, 3, 5, 6, 2, 1];
    end
end

bitnum = 3;
thresh = [1:(2^bitnum - 1)] * (256 / 2^bitnum) - 1;

upperbound = 255;
lowerbound = 0;
for i = 1:image_index - 1
    [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighborhoods(sequence(i)), shifts(sequence(i)));
end

x_inter_prediction = (upperbound + lowerbound) / 2 + shifts(image_index);
x_inter_prediction = (imquantize(x_inter_prediction, thresh) - 1);
