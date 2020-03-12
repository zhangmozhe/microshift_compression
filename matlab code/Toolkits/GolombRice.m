function encoded_bitstream = GolombRice(input, k, qbpp, limit)
% parameters:
% input: input number for encoding
% k: Rice code parameter
% qbpp: bit depth of the image
% limit: limit the code length
% reference: LOCO_I limit length Golomb code

%% extract the unary and binary part
%convert to binary string, truncate by k and convert back to uint
mErrVal_temp_bin = dec2bin(input, qbpp);
%will need this value as well
mErrVal_temp_bin_trunc = mErrVal_temp_bin(1:qbpp-k);
%keep k lsb values, we'll need these for bitstream
mErrVal_temp_bin_k_values = mErrVal_temp_bin(qbpp-k+1:qbpp);
%encoded_mapped_error_value_truncate = bin2dec(mErrVal_temp_bin_trunc);
encoded_mapped_error_value_truncate = sum((mErrVal_temp_bin_trunc - '0').*pow2(length(mErrVal_temp_bin_trunc)-1:-1:0), 2);


encoded_bitstream = [];

%% normal Golomb/Rice coding
if encoded_mapped_error_value_truncate < (limit - qbpp - 1)
    %add number of zeros unary by that number
    encoded_bitstream_tmp = repmat('1', 1, encoded_mapped_error_value_truncate);
    %   encoded_bitstream_tmp=[];
    %     for g = 1:encoded_mapped_error_value_truncate
    %         %append bitstream
    %         encoded_bitstream_tmp = [encoded_bitstream_tmp,'1'];    % unary encoding
    %     end
    %append binary 1 after loop
    encoded_bitstream_tmp1 = [encoded_bitstream_tmp, '0'];
    %lastly add k lsb values as they are to bitstream
    encoded_bitstream = [encoded_bitstream_tmp1, mErrVal_temp_bin_k_values]; % last k lsb

    %% limited Golomb/Rice coding
else
    %else use this number of 0s
    for g = 1:(limit - qbpp - 1)
        %append bitstream
        encoded_bitstream = strcat(encoded_bitstream, '1');
    end
    %append binary 1 after loop
    encoded_bitstream = strcat(encoded_bitstream, '0');
    %append mapped_error_value-1 in binary to end
    mErrVal_temp_bin_m1 = dec2bin(input-1, qbpp);
    encoded_bitstream = strcat(encoded_bitstream, mErrVal_temp_bin_m1);
end
