function [encoded_bitstream, bitstream_index, run_count] = runlength_encoding_mode(run_count, run_value, J, image, ...
    x, a, b, encoded_bitstream, bitstream_index, EOL, qbpp_runlength, ...
    limit_runlength, k_runlength, reset, bitnum, width)

if nargin < 2
    J = [0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, ... %change????????????????
        4, 4, 5, 5, 6, 6, 7, 7, 8, 9, 10, 11, 12, 13, 14, 15];
    bitstream_index = 0;
    encoded_bitstream = repmat('', 1, 100);
    EOL = 0;
end
persistent Nn A N
if isempty(A)
    A = ones(1, 2);
    N = ones(1, 2);
    Nn = zeros(1, 2);
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
if (run_count > 0 || run_index == 1) % extra segments or run is 0
    if (EOL == 1) % end of line
        bitstream_index = bitstream_index + 1;
        encoded_bitstream(bitstream_index) = '1';
    else % x ~= run_value
        bitstream_index = bitstream_index + 1;
        encoded_bitstream(bitstream_index) = '0';

        temp_runcount_binary = dec2bin(run_count, J(run_index)); % create binary with the size of J(run_index)
        if ~strcmp(temp_runcount_binary, '')
            encoded_bitstream((bitstream_index + 1):(bitstream_index + J(run_index))) = temp_runcount_binary;
            bitstream_index = bitstream_index + J(run_index);
        end

        if (run_index > 1)
            run_index = run_index - 1;
        end
    end
end

% encode interruption
if (x ~= run_value)
    if (a == b)
        run_interrupt_type = 1; % a==b
    else
        run_interrupt_type = 0; % a~=b
    end

    %% error prediction
    if (run_interrupt_type)
        predict_x = a;
    else
        predict_x = b;
    end
    error_value = x - predict_x;

    %% merge context
    if ((run_interrupt_type == 0) && (a > b))
        error_value = -error_value;
        sign = 0;
    else
        sign = 1;
    end

    %% interrupt type
    if (run_interrupt_type == 0)
        temp_run_index = A(1);
    else
        temp_run_index = A(2) + bitsrl1(cast(N(2), 'uint8'), 1);
    end
    map_index = run_interrupt_type + 1;

    %% compute k
    for k = 0:8
        if bitsll(N(map_index), k) >= temp_run_index
            var_k = k; % set Golomb global to k
            break;
        end
    end

    %     k = k_runlength;  %????????

    %% compute aux 'map' for error mapping
    if ((k == 0) && (error_value > 0) && (2 * Nn(map_index) < N(map_index)))
        map = 1;
    elseif ((error_value < 0) && (2 * Nn(map_index) >= N(map_index)))
        map = 1;
    elseif ((error_value < 0) && (k ~= 0))
        map = 1;
    else
        map = 0;
    end

    %% error mapping
    error_value = cast(error_value, 'uint8');
    mapped_run_error_value = (2 * abs(error_value)) - run_interrupt_type - map;


    % encode the interrupt variable
    code = GolombRice(mapped_run_error_value, k_runlength, qbpp_runlength, (limit_runlength - J(run_index_fixed) - 1)); %!!!!
    for i = 1:length(code)
        bitstream_index = bitstream_index + 1;
        encoded_bitstream(bitstream_index) = code(i);
    end

    % update the variables for context modeling in the runlength mode
    if (error_value < 0)
        Nn(map_index) = Nn(map_index) + 1;
    end
    A(map_index) = A(map_index) + bitsrl1(cast((mapped_run_error_value + 1 - run_interrupt_type), 'uint8'), 1);
    if (N(map_index) == reset)
        A(map_index) = bitsrl1(cast(A(map_index), 'uint8'), 1);
        N(map_index) = bitsrl1(cast(N(map_index), 'uint8'), 1);
        Nn(map_index) = bitsrl1(cast(Nn(map_index), 'uint8'), 1);
    end
    N(map_index) = N(map_index) + 1;


end
end


function result = bitsrl1(a, k)
result = floor(a/(2^k));
end
