function k_runlength = k_runlength_compute(map_index,A,N,run_interrupt_type)

if (run_interrupt_type == 0)
    temp_run_index = A(1);
else
    temp_run_index = A(2) + bitsrl1(cast(N(2),'uint8'),1);
end
for k=0:8
    if bitsll(N(map_index),k)>=temp_run_index
        var_k = k; % set Golomb global to k
        break;
    end
end
k_runlength = k;
