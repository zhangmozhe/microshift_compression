function [bitstream, bitstream_length] = GolombRice_hdl(input)
% Golomb_table = [...
%     '0',...
%     '10',...
%     '110',...
%     '1110',...
%     '11110',...
%     '111110',...
%     '1111110',...
%     '11111110',...
%     '111111110',...
%     '1111111110',...
%     '11111111110',...
%     '111111111110',...
%     '1111111111110',...
%     '11111111111110',...
%     '111111111111110',...
%     '1111111111111110',...
%     '11111111111111110',...
%     '111111111111111110',...
%     '1111111111111111110']; % 18

if input <= 15
    switch input
        case 0
            bitstream = fi(0, 0, 16, 0);
            bitstream_length = uint8(1);
        case 1
            bitstream = fi(2, 0, 16, 0);
            bitstream_length = uint8(2);
        case 2
            bitstream = fi(6, 0, 16, 0);
            bitstream_length = uint8(3);
        case 3
            bitstream = fi(14, 0, 16, 0);
            bitstream_length = uint8(4);
        case 4
            bitstream = fi(30, 0, 16, 0);
            bitstream_length = uint8(5);
        case 5
            bitstream = fi(62, 0, 16, 0);
            bitstream_length = uint8(6);
        case 6
            bitstream = fi(126, 0, 16, 0);
            bitstream_length = uint8(7);
        case 7
            bitstream = fi(254, 0, 16, 0);
            bitstream_length = uint8(8);
        case 8
            bitstream = fi(510, 0, 16, 0);
            bitstream_length = uint8(9);
        case 9
            bitstream = fi(1022, 0, 16, 0);
            bitstream_length = uint8(10);
        case 10
            bitstream = fi(2046, 0, 16, 0);
            bitstream_length = uint8(11);
        case 11
            bitstream = fi(4094, 0, 16, 0);
            bitstream_length = uint8(12);
        case 12
            bitstream = fi(8190, 0, 16, 0);
            bitstream_length = uint8(13);
        case 13
            bitstream = fi(16382, 0, 16, 0);
            bitstream_length = uint8(14);
        case 14
            bitstream = fi(32766, 0, 16, 0);
            bitstream_length = uint8(15);
        case 15
            bitstream = fi(65534, 0, 16, 0);
            bitstream_length = uint8(16);
        otherwise
            bitstream = fi(0, 0, 16, 0);
            bitstream_length = uint8(0);
    end
else
    bitstream = fi(0, 0, 16, 0);
    bitstream_length = uint8(0);
end

end % endo of GolombRice