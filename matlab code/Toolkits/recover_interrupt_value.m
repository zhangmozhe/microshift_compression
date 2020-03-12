function [interrupt_value, error_value] = recover_interrupt_value(mapped_run_error_value, run_interrupt_type, range, a, b)

predict_x = a;
% error_value = ModRange_reverse(predict_x,error_value,range);
error_value = remap(mapped_run_error_value+run_interrupt_type, predict_x, range);
% context merge back
if ((run_interrupt_type == 0) && (b > a))
    error_value = -error_value;
end

% calculte real value based on error_value
interrupt_value = error_value + predict_x;