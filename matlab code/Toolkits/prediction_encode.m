function [mapped_error_vector, encoded_bitstream, bitstream_index] = prediction_encode(x, predict_x, prediction_mode, index, encoded_bitstream, bitstream_index, k, qbpp, limit, range, mapped_error_vector, encode_mode)

% prediction
if prediction_mode
    mapped_error_vector(index) = x - predict_x;
    error_value = mapped_error_vector(index);
    mapped_error_value = error_mapping(error_value, predict_x, range);
else
    mapped_error_value = x; % if prediction_mode == 0, input x is the mapped error_value
end

% code the error_value with Golomb/Rice codes
if (encode_mode == 1)
    code = GolombRice(mapped_error_value, k, qbpp, limit);

    % code
    mapped_error_vector(index) = mapped_error_value;
    for i = 1:length(code)
        bitstream_index = bitstream_index + 1;
        encoded_bitstream(bitstream_index) = code(i);
    end

else
    mapped_error_vector(index) = mapped_error_value;
end