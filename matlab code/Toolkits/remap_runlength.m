function error_value = remap_runlength(error_value, run_interrupt_type, map, map_index, Nn, N, k)

if ((k == 0) && (map == 0) && (2 * Nn(map_index) < N(map_index)))
    error_value = -error_value;
else
    if ((map == 1) && (2 * Nn(map_index) >= N(map_index)))
        error_value = -error_value;
    else
        if ((map == 1) && (k ~= 0))
            error_value = -error_value;
        end
    end
end


if ((run_interrupt_type == 0) && (Rb < Ra))
    error_value = -error_value;
end