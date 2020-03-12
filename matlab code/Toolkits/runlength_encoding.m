function [encoded_bitstream, bitstream_index, run_index_fixed] = runlength_encoding(run_count, EOL, J, encoded_bitstream, bitstream_index)
% encode the runlength count

if nargin < 2 % for testing
    EOL = 0;
    J = [0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, ... % hit run lengths
        4, 4, 5, 5, 6, 6, 7, 7, 8, 9, 10, 11, 12, 13, 14, 15];
    encoded_bitstream = repmat('', 1, 100);
    bitstream_index = 0;
end

run_index = 1;

%% hit maximum runlengths
for j = 1:run_count
    if (run_count < bitsll(1, J(run_index)))
        break;
    end

    bitstream_index = bitstream_index + 1;
    encoded_bitstream(bitstream_index) = '1';

    run_count = run_count - bitsll(1, J(run_index));
    if (run_index < length(J))
        run_index = run_index + 1;
    end
end

run_index_fixed = run_index; % hold run_index before decrement

%% miss the runlengths or EOL = 1
% if(run_count > 0 || run_index == 1) % extra segments or run is 0
if (EOL == 1) % end of line
    if (run_count > 0)
        bitstream_index = bitstream_index + 1;
        encoded_bitstream(bitstream_index) = '1';
    end
else % x ~= run_value
    bitstream_index = bitstream_index + 1;
    encoded_bitstream(bitstream_index) = '0';

    temp_runcount_binary = dec2bin(run_count, J(run_index)); % create binary with the size of J(run_index)
    if ~isempty(temp_runcount_binary)
        encoded_bitstream((bitstream_index + 1):(bitstream_index + J(run_index))) = temp_runcount_binary;
        bitstream_index = bitstream_index + J(run_index);
    end

    if (run_index > 1)
        run_index = run_index - 1;
    end
end
% end