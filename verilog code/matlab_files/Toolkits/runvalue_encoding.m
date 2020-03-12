function [encoded_bitstream,bitstream_index,A,N,Nn,mapped_run_error_value] = runvalue_encoding(x,run_value,...
    encoded_bitstream,bitstream_index,run_index_fixed,a,b,...
    k_runlength,qbpp_runlength,limit_runlength,range,reset,J,A,N,Nn,encode_mode)
% encode the interruption value for the runlength mode

% encode interruption
if (x ~= run_value)
    if (b==a)
        run_interrupt_type = 1;  % b==a
    else
        run_interrupt_type = 0;  % b~=a
    end
    
    %% error prediction
    predict_x = a;
    error_value = x - predict_x;
    
    %% merge context
    if ((run_interrupt_type == 0) && (b>a))
        error_value = - error_value;
    end
    error_value0 = error_value;
%     error_value = ModRange(error_value,range); % mod range????????
    
%     %% interrupt type
%     map_index = run_interrupt_type + 1;
    
    %% adaptive k (optional)
    k = k_runlength;
%     if (run_interrupt_type == 0)
%         temp_run_index = A(1);
%     else
%         temp_run_index = A(2) + bitsrl1(cast(N(2),'uint8'),1);
%     end
%     for k = 0:8
%         if bitsll(N(map_index),k)>=temp_run_index
%             var_k = k; % set Golomb global to k
%             break;
%         end
%     end
%     if (k_runlength >= 0)
%         k = k_runlength;
%     end
    

%     %% compute aux 'map' for error mapping
%     if ((k == 0) && (error_value > 0) && (2 * Nn(map_index) < N(map_index)))
%         map = 1;
%     elseif ((error_value < 0) && (2 * Nn(map_index) >= N(map_index)))
%         map = 1;
%     elseif ((error_value < 0) && (k ~= 0))
%         map = 1;
%     else
%         map = 0;
%     end
%     
%     % error mapping
%     % error_value = cast(error_value,'uint8');
%     mapped_run_error_value = (2 * abs(error_value)) - run_interrupt_type - map;
    
    mapped_run_error_value = error_mapping(error_value0,predict_x,range) - run_interrupt_type;
    
 
    %% encode the interrupt variable
    if (encode_mode == 1)
        code = GolombRice(mapped_run_error_value,k,qbpp_runlength,(limit_runlength -J(run_index_fixed) - 1)); %!!!!
        for i=1:length(code)
            bitstream_index = bitstream_index + 1;
            encoded_bitstream(bitstream_index) = code(i);
        end
    end
    
    
%     % update the variables for context modeling in the runlength mode
%     if (error_value < 0)
%         Nn(map_index) = Nn(map_index) + 1;
%     end
%     A(map_index) = A(map_index) + bitsrl1(cast((mapped_run_error_value + 1 - run_interrupt_type),'uint8'),1);
%     if (N(map_index) == reset)
%         A(map_index) = bitsrl1(cast(A(map_index),'uint8'),1);
%         N(map_index) = bitsrl1(cast(N(map_index),'uint8'),1);
%         Nn(map_index) = bitsrl1(cast(Nn(map_index),'uint8'),1);
%     end
%     N(map_index) = N(map_index) + 1;

else
    mapped_run_error_value = [];
end

end


% function result = bitsrl1(b,k)
% result = floor(b/(2^k));
% end

