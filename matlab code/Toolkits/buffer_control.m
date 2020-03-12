function [tx_data_valid, tx_channel, tx_four_out, tx_data_out1, tx_data_out2, tx_data_out3, tx_data_out4, tx_bits_available, ...
    bitstream_ready_output, bitstream_length_output, hStart_output, hEnd_output, vStart_output, vEnd_output, valid_output, pixelOut] = ...
    buffer_control(bitstream_ready, bitstream_length, subimage_index_delay, bitstream, mode, hStart, hEnd, vStart, vEnd, valid, pixelOut_tmp)

% bitstream_ready: the input bitstream is valid
% bittream_length: the length of the bitstream
% subimage_index_delay: the subimage that is being processed
% bitstream: the bitstream that will be fed into the buffer
% mode: the compression mode
% pixIn: the raw pixel data

%% bitstream output
% write/read the corresponding channel
mode_newtype = uint8(mode);
switch mode_newtype
    case uint8(0) % no compression mode
        dump_mode = false;
    case uint8(1) % compression without internal psd
        dump_mode = false;
    case uint8(2) % compression with internal psd
        dump_mode = false;
    case uint8(3) % dump mode
        dump_mode = true;
    otherwise
        dump_mode = true;
end

if vStart && hStart
    reset = true;
else
    reset = false;
end

% if mode
[tx_data_valid, tx_channel, tx_four_out, tx_data_out1, tx_data_out2, tx_data_out3, tx_data_out4, tx_bits_available] = ...
    encoded_bitstream_outputs_hdl(bitstream_ready, bitstream_length, subimage_index_delay, bitstream, dump_mode, reset);

bitstream_ready_output = bitstream_ready;
bitstream_length_output = bitstream_length;
hStart_output = hStart;
hEnd_output = hEnd;
vStart_output = vStart;
vEnd_output = vEnd;
valid_output = valid;
pixelOut = pixelOut_tmp;