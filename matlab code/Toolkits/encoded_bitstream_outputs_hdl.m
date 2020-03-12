function [tx_data_valid, tx_channel, tx_four_out, tx_data_out1, tx_data_out2, tx_data_out3, tx_data_out4, tx_bits_available_output] ...
    = encoded_bitstream_outputs_hdl(bitstream_ready, bitstream_length, subimage_index_delay, bitstream, dump_mode, reset)
% tail: to be written in the next time;
% head: read-out in the last time

% the pixel index in the subimage
persistent first_pixel1 first_pixel2 first_pixel3 first_pixel4 first_pixel5 first_pixel6 first_pixel7 first_pixel8 first_pixel9;
if isempty(first_pixel1) || reset
    first_pixel1 = true;
    first_pixel2 = true;
    first_pixel3 = true;
    first_pixel4 = true;
    first_pixel5 = true;
    first_pixel6 = true;
    first_pixel7 = true;
    first_pixel8 = true;
    first_pixel9 = true;
end

% the subimage that is being dumped out
persistent dump_index;
if isempty(dump_index)
    dump_index = fi(1, 0, 4, 0);
end


% fifo declaration
FIFO_SIZE = uint8(128);
persistent head1 tail1 fifo1 tx_bits_available1;
if isempty(fifo1) || reset
    head1 = uint8(1);
    tail1 = uint8(2);
    fifo1 = fi(zeros(1, FIFO_SIZE), 0, 1, 0);
    tx_bits_available1 = int8(0);
end
persistent head2 tail2 fifo2 tx_bits_available2;
if isempty(fifo2) || reset
    head2 = uint8(1);
    tail2 = uint8(2);
    fifo2 = fi(zeros(1, FIFO_SIZE), 0, 1, 0);
    tx_bits_available2 = int8(0);
end
persistent head3 tail3 fifo3 tx_bits_available3;
if isempty(fifo3) || reset
    head3 = uint8(1);
    tail3 = uint8(2);
    fifo3 = fi(zeros(1, FIFO_SIZE), 0, 1, 0);
    tx_bits_available3 = int8(0);
end
persistent head4 tail4 fifo4 tx_bits_available4;
if isempty(fifo4) || reset
    head4 = uint8(1);
    tail4 = uint8(2);
    fifo4 = fi(zeros(1, FIFO_SIZE), 0, 1, 0);
    tx_bits_available4 = int8(0);
end
persistent head5 tail5 fifo5 tx_bits_available5;
if isempty(fifo5) || reset
    head5 = uint8(1);
    tail5 = uint8(2);
    fifo5 = fi(zeros(1, FIFO_SIZE), 0, 1, 0);
    tx_bits_available5 = int8(0);
end
persistent head6 tail6 fifo6 tx_bits_available6;
if isempty(fifo6) || reset
    head6 = uint8(1);
    tail6 = uint8(2);
    fifo6 = fi(zeros(1, FIFO_SIZE), 0, 1, 0);
    tx_bits_available6 = int8(0);
end
persistent head7 tail7 fifo7 tx_bits_available7;
if isempty(fifo7) || reset
    head7 = uint8(1);
    tail7 = uint8(2);
    fifo7 = fi(zeros(1, FIFO_SIZE), 0, 1, 0);
    tx_bits_available7 = int8(0);
end
persistent head8 tail8 fifo8 tx_bits_available8;
if isempty(fifo8) || reset
    head8 = uint8(1);
    tail8 = uint8(2);
    fifo8 = fi(zeros(1, FIFO_SIZE), 0, 1, 0);
    tx_bits_available8 = int8(0);
end
persistent head9 tail9 fifo9 tx_bits_available9;
if isempty(fifo9) || reset
    head9 = uint8(1);
    tail9 = uint8(2);
    fifo9 = fi(zeros(1, FIFO_SIZE), 0, 1, 0);
    tx_bits_available9 = int8(0);
end

%% state machine: write/read mode; dump mode; invalid mode
S0 = uint8(0);
S1 = uint8(1);
S2 = uint8(2);
if (bitstream_ready && bitstream_length > 0 && ~dump_mode)
    current_state = S0;
elseif dump_mode
    current_state = S1;
else % not valid pixel
    current_state = S2;
end

% demultiplex
if (current_state == S0)
    tx_channel = subimage_index_delay;
else
    tx_channel = dump_index;
end
switch tx_channel
    case uint8(1)
        fifo = fifo1;
        head = head1;
        tail = tail1;
        tx_bits_available = tx_bits_available1;
        first_pixel = first_pixel1;
    case uint8(2)
        fifo = fifo2;
        head = head2;
        tail = tail2;
        tx_bits_available = tx_bits_available2;
        first_pixel = first_pixel2;
    case uint8(3)
        fifo = fifo3;
        head = head3;
        tail = tail3;
        tx_bits_available = tx_bits_available3;
        first_pixel = first_pixel3;
    case uint8(4)
        fifo = fifo4;
        head = head4;
        tail = tail4;
        tx_bits_available = tx_bits_available4;
        first_pixel = first_pixel4;
    case uint8(5)
        fifo = fifo5;
        head = head5;
        tail = tail5;
        tx_bits_available = tx_bits_available5;
        first_pixel = first_pixel5;
    case uint8(6)
        fifo = fifo6;
        head = head6;
        tail = tail6;
        tx_bits_available = tx_bits_available6;
        first_pixel = first_pixel6;
    case uint8(7)
        fifo = fifo7;
        head = head7;
        tail = tail7;
        tx_bits_available = tx_bits_available7;
        first_pixel = first_pixel7;
    case uint8(8)
        fifo = fifo8;
        head = head8;
        tail = tail8;
        tx_bits_available = tx_bits_available8;
        first_pixel = first_pixel8;
    case uint8(9)
        fifo = fifo9;
        head = head9;
        tail = tail9;
        tx_bits_available = tx_bits_available9;
        first_pixel = first_pixel9;
    otherwise
        fifo = fifo1;
        head = head1;
        tail = tail1;
        tx_bits_available = tx_bits_available1;
        first_pixel = first_pixel1;
end

% slice bitstream
bit_in1 = bitget(bitstream, uint8(1));
bit_in2 = bitget(bitstream, uint8(2));
bit_in3 = bitget(bitstream, uint8(3));
bit_in4 = bitget(bitstream, uint8(4));
bit_in5 = bitget(bitstream, uint8(5));
bit_in6 = bitget(bitstream, uint8(6));
bit_in7 = bitget(bitstream, uint8(7));
bit_in8 = bitget(bitstream, uint8(8));
bit_in9 = bitget(bitstream, uint8(9));
bit_in10 = bitget(bitstream, uint8(10));


% switch current_state
%     case S0 % write/read mode
% %         [fifo,head,tail,first_pixel,tx_bits_available,tx_data_valid,tx_data_out1,tx_data_out2,tx_data_out3,tx_data_out4] =...
% %             write_read(fifo,head,tail,tx_bits_available,first_pixel,bitstream,bitstream_length,FIFO_SIZE);
%         [fifo,head,tail,first_pixel,tx_bits_available,tx_data_valid,tx_data_out1,tx_data_out2,tx_data_out3,tx_data_out4] = ...
%             write_read(fifo,head,tail,tx_bits_available,first_pixel,bit_in1,bit_in2,bit_in3,...
%             bit_in4,bit_in5,bit_in6,bit_in7,bit_in8,bit_in9,bit_in10,bitstream_length,FIFO_SIZE);
%
%     case S1 % dump mode
%         [head,tx_bits_available,tx_data_valid,tx_data_out1,tx_data_out2,tx_data_out3,tx_data_out4] = ...
%             dump(fifo,head,tx_bits_available,FIFO_SIZE);
%
%     otherwise  % invalid mode
%         tx_data_valid = false;
%         tx_data_out1 = fi(0,0,1,0);
%         tx_data_out2 = fi(0,0,1,0);
%         tx_data_out3 = fi(0,0,1,0);
%         tx_data_out4 = fi(0,0,1,0);
%         tx_bits_available = uint8(0);
%         tx_channel = uint8(0);
% end

[fifo_mode0, head_mode0, tail_mode0, first_pixel_mode0, tx_bits_available_mode0, tx_data_valid_mode0, tx_data_out1_mode0, tx_data_out2_mode0, tx_data_out3_mode0, tx_data_out4_mode0] = write_read(fifo, head, tail, tx_bits_available, first_pixel, ...
    bit_in1, bit_in2, bit_in3, bit_in4, bit_in5, bit_in6, bit_in7, bit_in8, bit_in9, bit_in10, bitstream_length, FIFO_SIZE, current_state);
[head_mode1, tx_bits_available_mode1, tx_data_valid_mode1, tx_data_out1_mode1, tx_data_out2_mode1, tx_data_out3_mode1, tx_data_out4_mode1, dump_index_temp] = ...
    dump(fifo, head, tx_bits_available, FIFO_SIZE, current_state, dump_index);

switch current_state
    case S0 % write/read mode
        fifo = fifo_mode0;
        head = head_mode0;
        tail = tail_mode0;
        first_pixel = first_pixel_mode0;
        tx_bits_available = tx_bits_available_mode0;
        tx_data_valid = tx_data_valid_mode0;
        tx_data_out1 = tx_data_out1_mode0;
        tx_data_out2 = tx_data_out2_mode0;
        tx_data_out3 = tx_data_out3_mode0;
        tx_data_out4 = tx_data_out4_mode0;

    case S1 % dump mode
        head = head_mode1;
        tx_bits_available = tx_bits_available_mode1;
        tx_data_valid = tx_data_valid_mode1;
        tx_data_out1 = tx_data_out1_mode1;
        tx_data_out2 = tx_data_out2_mode1;
        tx_data_out3 = tx_data_out3_mode1;
        tx_data_out4 = tx_data_out4_mode1;
        dump_index = dump_index_temp;

    otherwise % invalid mode
        tx_data_valid = false;
        tx_data_out1 = fi(0, 0, 1, 0);
        tx_data_out2 = fi(0, 0, 1, 0);
        tx_data_out3 = fi(0, 0, 1, 0);
        tx_data_out4 = fi(0, 0, 1, 0);
        tx_bits_available = int8(0);
        tx_channel = fi(0, 0, 4, 0);
end


if tx_data_valid && (current_state == S0)
    tx_four_out = true;
else
    tx_four_out = false;
end

%% multiplexer
if (current_state ~= S2)
    switch tx_channel
        case uint8(1)
            fifo1 = fifo;
            head1 = head;
            tail1 = tail;
            tx_bits_available1 = tx_bits_available;
            first_pixel1 = first_pixel;
        case uint8(2)
            fifo2 = fifo;
            head2 = head;
            tail2 = tail;
            tx_bits_available2 = tx_bits_available;
            first_pixel2 = first_pixel;
        case uint8(3)
            fifo3 = fifo;
            head3 = head;
            tail3 = tail;
            tx_bits_available3 = tx_bits_available;
            first_pixel3 = first_pixel;
        case uint8(4)
            fifo4 = fifo;
            head4 = head;
            tail4 = tail;
            tx_bits_available4 = tx_bits_available;
            first_pixel4 = first_pixel;
        case uint8(5)
            fifo5 = fifo;
            head5 = head;
            tail5 = tail;
            tx_bits_available5 = tx_bits_available;
            first_pixel5 = first_pixel;
        case uint8(6)
            fifo6 = fifo;
            head6 = head;
            tail6 = tail;
            tx_bits_available6 = tx_bits_available;
            first_pixel6 = first_pixel;
        case uint8(7)
            fifo7 = fifo;
            head7 = head;
            tail7 = tail;
            tx_bits_available7 = tx_bits_available;
            first_pixel7 = first_pixel;
        case uint8(8)
            fifo8 = fifo;
            head8 = head;
            tail8 = tail;
            tx_bits_available8 = tx_bits_available;
            first_pixel8 = first_pixel;
        case uint8(9)
            fifo9 = fifo;
            head9 = head;
            tail9 = tail;
            tx_bits_available9 = tx_bits_available;
            first_pixel9 = first_pixel;
    end
end

tx_bits_available_output = fi(tx_bits_available, 0, 4, 0);
