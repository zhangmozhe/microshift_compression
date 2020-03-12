function [map, error_value] = runlength_map_decoder(mapped_run_error_value, run_interrupt_type)

if bitand(mapped_run_error_value, 1)
    if (run_interrupt_type == 1)
        map = 0;
        error_value = bitsrl1((mapped_run_error_value + 1), 1);
    else
        map = 1;
        error_value = bitsrl1((mapped_run_error_value + 1), 1);
    end
else
    if (run_interrupt_type == 1)
        map = 1;
        error_value = bitsrl1((mapped_run_error_value + 2), 1);
    else
        map = 0;
        error_value = bitsrl1(mapped_run_error_value, 1);
    end
end
end % end of function
