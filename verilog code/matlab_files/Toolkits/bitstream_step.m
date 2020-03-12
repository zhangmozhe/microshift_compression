function [code, bitstream_index, code_runlength] = bitstream_step(encoded_bitstream, bitstream_index, mode, k, qbpp, limit, J, max_length)

%% step out code for runlength
if (mode == 1) % runlength decoder
    code0 = [];
    run_index = 1;
    length_now = J(run_index);
    bitstream_index_max = length(encoded_bitstream);
    
    while(encoded_bitstream(bitstream_index) == '1' && length_now <= max_length) % hit code
        code0 = [code0, encoded_bitstream(bitstream_index)];
        bitstream_index = bitstream_index + 1;
        length_now = length_now + bitsll(1,J(run_index));
        if (run_index < length(J))
            run_index = run_index + 1;
        end
        if (bitstream_index > bitstream_index_max || length_now >= max_length)
           break; 
        end
    end
    
    if(length_now >= max_length) % EOL
        if (length_now == max_length)
            code_runlength = code0;
            code = [];
            return
        else
            code_runlength = [code0, '1'];
            code = [];
            return;
        end
    else %'0' + binary bits
        code_runlength = [code0, '0'];
        bitstream_index = bitstream_index + 1;
        for i = 1:J(run_index)
            code_runlength = [code_runlength, encoded_bitstream(bitstream_index)];
            bitstream_index = bitstream_index + 1;
        end
    end
end

%% step out Golomb code
code0 = [];
g = 0;
while(encoded_bitstream(bitstream_index) == '1') % unary part
    code0 = [code0, encoded_bitstream(bitstream_index)];
    bitstream_index = bitstream_index + 1;
    g = g + 1;
end

code = [code0, '0'];
bitstream_index = bitstream_index + 1;

m = 2^k;
if m == 1
    n_binary = 0;
else
    n_binary = length(dec2bin(m-1)); % binary length
end
if (g < limit - qbpp - 1) % not limit
    for i = 1:n_binary
        code = [code, encoded_bitstream(bitstream_index)];
        bitstream_index = bitstream_index + 1;
    end
else % limited
    for i = 1:(limit - g - 1)
        code = [code, encoded_bitstream(bitstream_index)];
        bitstream_index = bitstream_index + 1;
    end
%     for i = 1:(limit - qbpp - 1)
%         code = [code, encoded_bitstream(bitstream_index)];
%         bitstream_index = bitstream_index + 1;
%     end
%     for i = 1:qbpp + 1
%         code = [code, encoded_bitstream(bitstream_index)];
%         bitstream_index = bitstream_index + 1;
%     end
end




