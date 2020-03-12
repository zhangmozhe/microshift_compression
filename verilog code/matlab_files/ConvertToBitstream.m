function bitstream = ConvertToBitstream(bitstream_values)

N = length(bitstream_values);
bitstream = [];
for i = 1:N
    bitstream = [bitstream,dec2bin(bitstream_values(i))];
end
