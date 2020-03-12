function [A, N, Nn] = run_update(A, N, Nn, error_value, mapped_run_error_value, map_index, reset, run_interrupt_type, a, b, range)

%% update the variables for context modeling in the runlength mode
% merge context
if (error_value ~= 0)
    error_value = ModRange(error_value, range);
    if ((run_interrupt_type == 0) && (b > a))
        error_value = -error_value;
    end

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
