function EOL = check_EOL(index, width, x, run_value)
% check whether is end of line for the runlength mode

if (mod(index, width) == 0)
    if (x == run_value)
        EOL = 1;
    else
        EOL = 0;
    end
else
    EOL = 0;
end