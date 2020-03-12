function [bitstream1, bitstream2, bitstream3, bitstream4, ...
    bitstream5, bitstream6, bitstream7, bitstream8, bitstream9] = bitstream_output(subimage_index_delay, bitstream)

switch subimage_index_delay
    case 1
        bitstream1 = bitstream;
        bitstream2 = '';
        bitstream3 = '';
        bitstream4 = '';
        bitstream5 = '';
        bitstream6 = '';
        bitstream7 = '';
        bitstream8 = '';
        bitstream9 = '';
    case 2
        bitstream1 = '';
        bitstream2 = bitstream;
        bitstream3 = '';
        bitstream4 = '';
        bitstream5 = '';
        bitstream6 = '';
        bitstream7 = '';
        bitstream8 = '';
        bitstream9 = '';
    case 3
        bitstream1 = '';
        bitstream2 = '';
        bitstream3 = bitstream;
        bitstream4 = '';
        bitstream5 = '';
        bitstream6 = '';
        bitstream7 = '';
        bitstream8 = '';
        bitstream9 = '';
    case 4
        bitstream1 = '';
        bitstream2 = '';
        bitstream3 = '';
        bitstream4 = bitstream;
        bitstream5 = '';
        bitstream6 = '';
        bitstream7 = '';
        bitstream8 = '';
        bitstream9 = '';
    case 5
        bitstream1 = '';
        bitstream2 = '';
        bitstream3 = '';
        bitstream4 = '';
        bitstream5 = bitstream;
        bitstream6 = '';
        bitstream7 = '';
        bitstream8 = '';
        bitstream9 = '';
    case 6
        bitstream1 = '';
        bitstream2 = '';
        bitstream3 = '';
        bitstream4 = '';
        bitstream5 = '';
        bitstream6 = bitstream;
        bitstream7 = '';
        bitstream8 = '';
        bitstream9 = '';
    case 7
        bitstream1 = '';
        bitstream2 = '';
        bitstream3 = '';
        bitstream4 = '';
        bitstream5 = '';
        bitstream6 = '';
        bitstream7 = bitstream;
        bitstream8 = '';
        bitstream9 = '';
    case 8
        bitstream1 = '';
        bitstream2 = '';
        bitstream3 = '';
        bitstream4 = '';
        bitstream5 = '';
        bitstream6 = '';
        bitstream7 = '';
        bitstream8 = bitstream;
        bitstream9 = '';
    case 9
        bitstream1 = '';
        bitstream2 = '';
        bitstream3 = '';
        bitstream4 = '';
        bitstream5 = '';
        bitstream6 = '';
        bitstream7 = '';
        bitstream8 = '';
        bitstream9 = bitstream;
    otherwise
        bitstream1 = '';
        bitstream2 = '';
        bitstream3 = '';
        bitstream4 = '';
        bitstream5 = '';
        bitstream6 = '';
        bitstream7 = '';
        bitstream8 = '';
        bitstream9 = '';
end