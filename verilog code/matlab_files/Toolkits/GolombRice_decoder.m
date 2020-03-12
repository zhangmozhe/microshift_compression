function decoder_output = GolombRice_decoder(input,k,qbpp,limit)
% parameters:
% input: input number for decoding
% k: Rice code parameter
% qbpp: bit depth of the image
% limit: limit the code length

% escape code
q_max = limit - qbpp - 1;  % max quantity that can be encoded without limitation
escape_code = [];
escape_code_unarycount = 0;

escape_code0 = repmat('1',1,limit - qbpp - 1);
escape_code_unarycount = (limit - qbpp - 1);

% for g = 1:(limit - qbpp - 1)
%     escape_code = strcat(escape_code,'1');
%     escape_code_unarycount = escape_code_unarycount + 1;
% end
escape_code = [escape_code0,'0'];

i = 1;
unary_count = 0;
while (strcmp(input(i),'1'))
    unary_count = unary_count + 1;
    i = i + 1;
end

i = i + 1;
if (unary_count < escape_code_unarycount)   % without limitation
    if (k == 0)
        binary_decoder = 0;
    else
        binary_part = input(i:end);
        binary_decoder = bin2dec(binary_part);
    end
    unarty_decoder = unary_count;
    decoder_output = unarty_decoder*(2^k) + binary_decoder;
else                                        % with limitation
    binary_part = input(i:end);
    binary_decoder = bin2dec(binary_part) + 1;
    decoder_output = binary_decoder;
end

