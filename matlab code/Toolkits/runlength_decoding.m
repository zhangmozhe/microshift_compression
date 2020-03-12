function [run_count, run_index_fixed, EOL] = runlength_decoding(code_runlength, J, max_length)

code_index = 1;
run_index = 1;
length_now = J(run_index);

while (code_runlength(code_index) == '1' && length_now < max_length) % hit code
    length_now = length_now + bitsll(1, J(run_index));
    code_index = code_index + 1;
    run_index = run_index + 1;
    if (length_now == max_length)
        break;
    end
end
run_index_fixed = run_index;


if (length_now >= max_length)
    run_count = max_length;
    EOL = 1;
else
    EOL = 0;
    binary_part = code_runlength(code_index+1:end);
    if isempty(binary_part)
        run_count = length_now;
    else
        run_count = bin2dec(binary_part) + length_now;
    end
end