function output = Arith_bitstream(input,mode)
% mode == 1: encoding mode
%            input: values to be encoded
%            output: bitstream

% mode == 2: decoding mode
%            input: bitstream
%            output: decoded values

if mode == 1
    xC{1} = input;
    code_integers = Arith(xC,mode);
    bitstream = repmat(char(0),1,length(code_integers)*8);
    for i = 1:length(code_integers)
        code = code_integers(i);
        code_bin = dec2bin(code,8);
        bitstream( (8*(i-1)+1): (8*(i-1)+8) ) = code_bin;
    end
    output = bitstream;
    
elseif mode == 2
    code_integers = length(input)/8;
    for i = 1:code_integers
        code = input((8*(i-1)+1): (8*(i-1)+8));
        code_integers(i) = bin2dec(code);
    end
    decoded_integers = Arith(code_integers,mode);
    output = decoded_integers{1};
end


