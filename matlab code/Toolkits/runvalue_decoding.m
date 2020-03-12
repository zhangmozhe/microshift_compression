function [interrupt_value, error_value, mapped_run_error_value] = runvalue_decoding(code, run_value, run_interrupt_type, map_index, run_index_fixed, ...
    a, b, k_runlength, qbpp_runlength, limit_runlength, range, J, N, Nn)
% decode the interruption value for the runlength mode

% if code is empty
if isempty(code)
    interrupt_value = run_value;
    error_value = 0;
    mapped_run_error_value = 0;
    return;
end

% map back
mapped_run_error_value = GolombRice_decoder(code, k_runlength, ...
    qbpp_runlength, (limit_runlength - J(run_index_fixed) - 1));

% [map,error_value] = runlength_map_decoder(mapped_run_error_value, run_interrupt_type);
% error_value = remap_runlength(error_value, run_interrupt_type,...
%     map, map_index, Nn, N, k_runlength);

% modulo reversion
[interrupt_value, error_value] = recover_interrupt_value(mapped_run_error_value, run_interrupt_type, range, a, b);
% predict_x = a;
% % error_value = ModRange_reverse(predict_x,error_value,range);
% error_value = remap(mapped_run_error_value + run_interrupt_type, predict_x, range);
% % context merge back
% if((run_interrupt_type == 0) && (b>a))
%     error_value = -error_value;
% end
%
% % calculte real value based on error_value
% interrupt_value = error_value + predict_x;


end % end of function