function [bitstream_ready, bitstream_length_output, subimage_index_output, bitstream_output, hStart_output, hEnd_output, vStart_output, vEnd_output, valid_output] ...
    = compression_hdl_lowpower(pixelIn, hStart, hEnd, vStart, vEnd, valid, mode)
% mode = 0: no compression;
% mode = 1: compression without psd;
% mode = 2: compression with psd; (only this mode in low power version)
% mode = 3: dump mode

% effective size: 48*64
width = uint16(216);
porch = uint16(20);
numCols = width + porch; % total number of columns, modify according to the testbench!
% F = fimath('OverflowAction','Wrap','RoundingMethod','Floor','SumMode','KeepLSB','SumWordLength',3);

persistent range;
if isempty(range)
    range = int8(8);
end

reset = hStart && vStart;

%% declare buffers (uint32)
% effective position counter (uint16)
% x_count_effective: [0,numRows_effective-1]
% y_count_effective: [0,numCols_effective-1]
persistent y_count_effective x_count_effective;
if isempty(y_count_effective) || reset
    y_count_effective = uint32(0);
end
if isempty(x_count_effective) || reset
    x_count_effective = uint32(0);
end
if valid
    if hStart && vStart % the first pixel of the whole frame
        y_count_effective = uint32(0);
    elseif hStart % the first pixel of the other line
        y_count_effective = uint32(0);
    else % the other pixels
        y_count_effective = y_count_effective + uint32(1);
    end
end
if valid
    if hStart && vStart % the first pixel of the whole frame
        x_count_effective = uint32(0);
    elseif hStart % the first pixel of the other line
        x_count_effective = x_count_effective + uint32(1);
    end
end


% line buffers
persistent linebuf1 linebuf2 linebuf3;
if isempty(linebuf1)
    linebuf1 = dsp.Delay('Length', numCols);
    linebuf2 = dsp.Delay('Length', numCols);
    linebuf3 = dsp.Delay('Length', numCols);
end

% unit delay
persistent a1 a2 a3 a4 a5 a6 a7 a8 a9;
if isempty(a1)
    a1 = dsp.Delay;
    a2 = dsp.Delay;
    a3 = dsp.Delay;
    a4 = dsp.Delay;
    a5 = dsp.Delay;
    a6 = dsp.Delay;
    a7 = dsp.Delay;
    a8 = dsp.Delay;
    a9 = dsp.Delay;
end
persistent b1 b2 b3 b4;
if isempty(b1)
    b1 = dsp.Delay;
    b2 = dsp.Delay;
    b3 = dsp.Delay;
    b4 = dsp.Delay;
end
persistent c1 c2 c3 c4;
if isempty(c1)
    c1 = dsp.Delay;
    c2 = dsp.Delay;
    c3 = dsp.Delay;
    c4 = dsp.Delay;
end
persistent d1 d2 d3 d4 d5 d6;
if isempty(d1)
    d1 = dsp.Delay;
    d2 = dsp.Delay;
    d3 = dsp.Delay;
    d4 = dsp.Delay;
    d5 = dsp.Delay;
    d6 = dsp.Delay;
end

% microshift index (uint8)
persistent x_microshift y_microshift;
if isempty(x_microshift) || reset
    x_microshift = uint8(0);
    y_microshift = uint8(0);
end
if valid
    if hStart && vStart % the first pixel of the whole frame
        y_microshift = uint8(0);
        x_microshift = uint8(0);
    elseif hStart % the first pixel of the other line
        y_microshift = uint8(0);
        x_microshift = x_microshift + uint8(1);
        if x_microshift == 3
            x_microshift = uint8(0);
        end
    else % the other pixels
        y_microshift = y_microshift + uint8(1);
        if y_microshift == 3
            y_microshift = uint8(0);
        end
    end
end

%% PSD compression (uint8)
% introduce distortions for valid regions
% distortion pattern = 0  4  7
%                     18 14 11
%                     21 25 28


if valid
    if (mode == 1)
        a0_value = fi(bitsrl(pixelIn, 5), 0, 3, 0);
    else
        if (x_microshift == 0) && (y_microshift == 0)
            a0_value = fi(bitsrl(pixelIn, 5), 0, 3, 0);
        elseif (x_microshift == 0) && (y_microshift == 1)
            a0_value = fi(bitsrl(pixelIn-uint8(4), 5), 0, 3, 0);
        elseif (x_microshift == 0) && (y_microshift == 2)
            a0_value = fi(bitsrl(pixelIn-uint8(7), 5), 0, 3, 0);
        elseif (x_microshift == 1) && (y_microshift == 0)
            a0_value = fi(bitsrl(pixelIn-uint8(18), 5), 0, 3, 0);
        elseif (x_microshift == 1) && (y_microshift == 1)
            a0_value = fi(bitsrl(pixelIn-uint8(14), 5), 0, 3, 0);
        elseif (x_microshift == 1) && (y_microshift == 2)
            a0_value = fi(bitsrl(pixelIn-uint8(11), 5), 0, 3, 0);
        elseif (x_microshift == 2) && (y_microshift == 0)
            a0_value = fi(bitsrl(pixelIn-uint8(21), 5), 0, 3, 0);
        elseif (x_microshift == 2) && (y_microshift == 1)
            a0_value = fi(bitsrl(pixelIn-uint8(25), 5), 0, 3, 0);
        elseif (x_microshift == 2) && (y_microshift == 2)
            a0_value = fi(bitsrl(pixelIn-uint8(28), 5), 0, 3, 0);
        else
            a0_value = fi(bitsrl(pixelIn, 5), 0, 3, 0);
        end
    end
else
    a0_value = fi(0, 0, 3, 0); % current pixel
end
% a0_value.fimath = F;

if valid
    if (x_microshift == 0) && (y_microshift == 0)
        subimage_index = uint8(1);
    elseif (x_microshift == 0) && (y_microshift == 1)
        subimage_index = uint8(2);
    elseif (x_microshift == 0) && (y_microshift == 2)
        subimage_index = uint8(3);
    elseif (x_microshift == 1) && (y_microshift == 0)
        subimage_index = uint8(6);
    elseif (x_microshift == 1) && (y_microshift == 1)
        subimage_index = uint8(5);
    elseif (x_microshift == 1) && (y_microshift == 2)
        subimage_index = uint8(4);
    elseif (x_microshift == 2) && (y_microshift == 0)
        subimage_index = uint8(7);
    elseif (x_microshift == 2) && (y_microshift == 1)
        subimage_index = uint8(8);
    elseif (x_microshift == 2) && (y_microshift == 2)
        subimage_index = uint8(9);
    else
        subimage_index = uint8(1);
    end
else
    subimage_index = uint8(1);
end

%% delayed values
% x_count_effective_delay: [0,numRows_effective-1]
% y_count_effective_delay: [0,numCols_effective-1]
persistent valid_buffer y_count_effective_buffer x_count_effective_buffer subimage_index_buffer
if isempty(valid_buffer)
    valid_buffer = dsp.Delay('Length', 3);
    y_count_effective_buffer = dsp.Delay('Length', 3);
    x_count_effective_buffer = dsp.Delay('Length', 3);
    subimage_index_buffer = dsp.Delay('Length', 3);
end
valid_delay = step(valid_buffer, valid);
x_count_effective_delay = step(x_count_effective_buffer, x_count_effective);
y_count_effective_delay = step(y_count_effective_buffer, y_count_effective);
subimage_index_delay = step(subimage_index_buffer, subimage_index);

%% adjacent pixels (note: pixels are fi3)
% pixels of the current line (fi3)
a1_value = step(a1, a0_value);
a2_value = step(a2, a1_value);
a3_value = step(a3, a2_value);
a4_value = step(a4, a3_value);
a5_value = step(a5, a4_value);
a6_value = step(a6, a5_value);
a7_value = step(a7, a6_value);
a8_value = step(a8, a7_value);
a9_value = step(a9, a8_value);

% pixels above the current line (fi3)
b0_value = step(linebuf1, a0_value);
b1_value = step(b1, b0_value);
b2_value = step(b2, b1_value);
b3_value = step(b3, b2_value);
b4_value = step(b4, b3_value);
% b5_value = step(b5,b4_value);
% b6_value = step(b6,b5_value);
% b7_value = step(b7,b6_value);
% b8_value = step(b8,b7_value);
% b9_value = step(b9,b8_value);

% pixels above above the current line (fi3)
c0_value = step(linebuf2, b0_value);
c1_value = step(c1, c0_value);
c2_value = step(c2, c1_value);
c3_value = step(c3, c2_value);
c4_value = step(c4, c3_value);
% c5_value = step(c5,c4_value);
% c6_value = step(c6,c5_value);
% c7_value = step(c7,c6_value);
% c8_value = step(c8,c7_value);
% c9_value = step(c9,c8_value);

% pixels above above above the current line (fi3)
d0_value = step(linebuf3, c0_value);
d1_value = step(d1, d0_value);
d2_value = step(d2, d1_value);
d3_value = step(d3, d2_value);
d4_value = step(d4, d3_value);
d5_value = step(d5, d4_value);
d6_value = step(d6, d5_value);
% d7_value = step(d7,d6_value);
% d8_value = step(d8,d7_value);
% d9_value = step(d9,d8_value);

%% pre-allocate bitstream memory
bitstream = fi(0, 0, 16, 0);
bitstream_length = uint8(0);
bitstream_ready = false;

%% pixel index in the subimage (uint16)
persistent pixel_subimage_index1 pixel_subimage_index2 pixel_subimage_index3 pixel_subimage_index4 pixel_subimage_index5 pixel_subimage_index6 pixel_subimage_index7 pixel_subimage_index8 pixel_subimage_index9;
if isempty(pixel_subimage_index1) || reset
    pixel_subimage_index1 = uint16(0);
    pixel_subimage_index2 = uint16(0);
    pixel_subimage_index3 = uint16(0);
    pixel_subimage_index4 = uint16(0);
    pixel_subimage_index5 = uint16(0);
    pixel_subimage_index6 = uint16(0);
    pixel_subimage_index7 = uint16(0);
    pixel_subimage_index8 = uint16(0);
    pixel_subimage_index9 = uint16(0);
end

%% reset registers before the compressing the current frame
if hStart && vStart
    pixel_subimage_index1 = uint16(0);
    pixel_subimage_index2 = uint16(0);
    pixel_subimage_index3 = uint16(0);
    pixel_subimage_index4 = uint16(0);
    pixel_subimage_index5 = uint16(0);
    pixel_subimage_index6 = uint16(0);
    pixel_subimage_index7 = uint16(0);
    pixel_subimage_index8 = uint16(0);
    pixel_subimage_index9 = uint16(0);
end

%% for state machines (uint8)
S0 = uint8(0); % predictive mode
S1 = uint8(1); % runlength accumulation mode
S2 = uint8(2); % runlength encode mode
persistent current_state1 current_state2 current_state3 current_state4 current_state5 ...
    current_state6 current_state7 current_state8 current_state9;
if isempty(current_state1) || reset
    current_state1 = S0;
    current_state2 = S0;
    current_state3 = S0;
    current_state4 = S0;
    current_state5 = S0;
    current_state6 = S0;
    current_state7 = S0;
    current_state8 = S0;
    current_state9 = S0;
end

%% for runlength (uint16)
persistent run_count1 run_count2 run_count3 run_count4 ...
    run_count5 run_count6 run_count7 run_count8 run_count9;
if isempty(run_count1) || reset
    run_count1 = uint16(0);
    run_count2 = uint16(0);
    run_count3 = uint16(0);
    run_count4 = uint16(0);
    run_count5 = uint16(0);
    run_count6 = uint16(0);
    run_count7 = uint16(0);
    run_count8 = uint16(0);
    run_count9 = uint16(0);
end
persistent run_value1 run_value2 run_value3 run_value4 ...
    run_value5 run_value6 run_value7 run_value8 run_value9;
if isempty(run_value1) || reset
    run_value1 = int8(0);
    run_value2 = int8(0);
    run_value3 = int8(0);
    run_value4 = int8(0);
    run_value5 = int8(0);
    run_value6 = int8(0);
    run_value7 = int8(0);
    run_value8 = int8(0);
    run_value9 = int8(0);
end

persistent residue_learned;
if isempty(residue_learned)
    %residue_learned = fi([0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;1;1;1;1;1;1;1;1;1;0;0;0;1;0;1;1;1;8;1;0;1;0;1;-1;0;-1;-1;-1;-1;0;0;0;0;-1;-1;-1;-1;-1;-1;0;0;-1;0;-1;-1;-1;-1;-1;8;0;1;0;2;0;0;0;1;8;0;0;1;0;2;0;0;8;1;8;0;0;1;0;2;0;0;0;-1;0;-2;0;0;-1;0;-2;0;-1;-1;-1;-2;0;0;0;0;-2;0;0;8;-2;8;1;1;1;1;1;1;1;1;1;1;0;0;0;1;0;1;1;1;8;1;0;1;1;1;1;1;1;1;2;1;1;1;1;2;1;1;1;1;2;1;1;1;2;8;1;1;2;1;2;1;0;0;0;0;0;0;1;0;1;0;0;0;0;0;-1;0;1;0;1;0;0;0;0;0;8;1;2;1;3;1;1;1;1;8;1;0;2;1;3;1;1;8;8;8;8;0;2;1;3;0;0;0;-1;0;-1;0;0;0;0;-1;0;0;-1;0;-2;0;0;1;1;-2;0;0;8;0;8;-1;-1;-1;-1;-1;0;0;-1;0;-1;-1;-1;-1;-1;-1;-1;-1;-1;-1;-1;-1;-1;-1;-1;8;0;0;0;0;0;0;0;0;0;0;0;0;-1;0;-1;0;0;0;8;0;0;0;-1;0;-1;-1;-1;-1;-1;-2;-1;-1;-1;-1;-2;-1;-1;-1;-1;-2;-1;-1;-2;-1;-2;-1;-1;8;-2;8;0;1;0;1;0;0;0;0;2;0;0;0;0;1;0;0;8;0;8;0;0;0;-1;2;-1;-1;-1;-2;-1;-3;-1;-1;-2;-1;-2;-1;-1;-1;-2;8;-1;-1;-2;-2;-3;0;8;8;8;8;2;2;2;2;2;2;2;2;2;2;1;2;2;2;2;2;2;2;8;2;2;2;1;2;3;2;3;2;3;3;1;2;1;8;3;2;2;2;3;2;1;8;1;8;3;1;3;2;3;3;1;1;1;1;0;1;2;1;2;0;0;1;0;1;0;1;2;0;2;0;0;1;1;1;0;2;3;2;3;3;1;8;1;8;8;2;3;2;8;3;8;8;8;8;8;1;2;2;8;2;0;0;0;0;-1;0;1;0;1;0;0;0;1;0;8;0;1;0;2;-2;0;0;1;0;8;-2;-2;-2;-2;-2;-2;-1;-2;-2;-2;-2;-2;-2;-2;-2;-2;-2;-2;-2;-2;-2;-2;-2;-2;8;-1;-1;-1;-1;-1;0;-1;-1;0;-1;-1;-1;-2;-1;-2;-1;-1;-1;-1;-1;0;0;-2;0;-3;-2;-2;-3;-2;-3;-2;-2;-2;-3;-3;-1;-2;-3;-3;8;-3;-3;-3;-3;-3;-1;-2;8;-3;8;0;0;0;0;0;0;-1;0;8;0;0;0;-1;-1;-1;0;0;0;8;0;0;-1;-2;2;-2;-2;-2;-3;-3;-3;-3;-3;-3;-3;8;-1;-1;-3;-1;8;-4;-4;8;-3;8;8;8;8;8;8],1,4,0);
    residue_learned = fi([0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 1; 1; 1; 1; 1; 1; 1; 1; 1; 0; 0; 0; 1; 0; 1; 1; 1; 7; 1; 0; 1; 0; 1; -1; 0; -1; -1; -1; -1; 0; 0; 0; 0; -1; -1; -1; -1; -1; -1; 0; 0; -1; 0; -1; -1; -1; -1; -1; 7; 0; 1; 0; 2; 0; 0; 0; 1; 7; 0; 0; 1; 0; 2; 0; 0; 7; 1; 7; 0; 0; 1; 0; 2; 0; 0; 0; -1; 0; -2; 0; 0; -1; 0; -2; 0; -1; -1; -1; -2; 0; 0; 0; 0; -2; 0; 0; 7; -2; 7; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 0; 0; 0; 1; 0; 1; 1; 1; 7; 1; 0; 1; 1; 1; 1; 1; 1; 1; 2; 1; 1; 1; 1; 2; 1; 1; 1; 1; 2; 1; 1; 1; 2; 7; 1; 1; 2; 1; 2; 1; 0; 0; 0; 0; 0; 0; 1; 0; 1; 0; 0; 0; 0; 0; -1; 0; 1; 0; 1; 0; 0; 0; 0; 0; 7; 1; 2; 1; 3; 1; 1; 1; 1; 7; 1; 0; 2; 1; 3; 1; 1; 7; 7; 7; 7; 0; 2; 1; 3; 0; 0; 0; -1; 0; -1; 0; 0; 0; 0; -1; 0; 0; -1; 0; -2; 0; 0; 1; 1; -2; 0; 0; 7; 0; 7; -1; -1; -1; -1; -1; 0; 0; -1; 0; -1; -1; -1; -1; -1; -1; -1; -1; -1; -1; -1; -1; -1; -1; -1; 7; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; -1; 0; -1; 0; 0; 0; 7; 0; 0; 0; -1; 0; -1; -1; -1; -1; -1; -2; -1; -1; -1; -1; -2; -1; -1; -1; -1; -2; -1; -1; -2; -1; -2; -1; -1; 7; -2; 7; 0; 1; 0; 1; 0; 0; 0; 0; 2; 0; 0; 0; 0; 1; 0; 0; 7; 0; 7; 0; 0; 0; -1; 2; -1; -1; -1; -2; -1; -3; -1; -1; -2; -1; -2; -1; -1; -1; -2; 7; -1; -1; -2; -2; -3; 0; 7; 7; 7; 7; 2; 2; 2; 2; 2; 2; 2; 2; 2; 2; 1; 2; 2; 2; 2; 2; 2; 2; 7; 2; 2; 2; 1; 2; 3; 2; 3; 2; 3; 3; 1; 2; 1; 7; 3; 2; 2; 2; 3; 2; 1; 7; 1; 7; 3; 1; 3; 2; 3; 3; 1; 1; 1; 1; 0; 1; 2; 1; 2; 0; 0; 1; 0; 1; 0; 1; 2; 0; 2; 0; 0; 1; 1; 1; 0; 2; 3; 2; 3; 3; 1; 7; 1; 7; 7; 2; 3; 2; 7; 3; 7; 7; 7; 7; 7; 1; 2; 2; 7; 2; 0; 0; 0; 0; -1; 0; 1; 0; 1; 0; 0; 0; 1; 0; 7; 0; 1; 0; 2; -2; 0; 0; 1; 0; 7; -2; -2; -2; -2; -2; -2; -1; -2; -2; -2; -2; -2; -2; -2; -2; -2; -2; -2; -2; -2; -2; -2; -2; -2; 7; -1; -1; -1; -1; -1; 0; -1; -1; 0; -1; -1; -1; -2; -1; -2; -1; -1; -1; -1; -1; 0; 0; -2; 0; -3; -2; -2; -3; -2; -3; -2; -2; -2; -3; -3; -1; -2; -3; -3; 7; -3; -3; -3; -3; -3; -1; -2; 7; -3; 7; 0; 0; 0; 0; 0; 0; -1; 0; 7; 0; 0; 0; -1; -1; -1; 0; 0; 0; 7; 0; 0; -1; -2; 2; -2; -2; -2; -3; -3; -3; -3; -3; -3; -3; 7; -1; -1; -3; -1; 7; -4; -4; 7; -3; 7; 7; 7; 7; 7; 7], 1, 3, 0);
end

%% compression (signed 3 bit interger)
if valid_delay % effective image region

    %% prepare location values for later calculation
    % real position for x (not the current scanning pixel)(start from 1)
    x_index = x_count_effective_delay + uint32(1);
    y_index = y_count_effective_delay + uint32(1);


    % real position at the scanning
    % x_index_scan = x_index;
    % y_index_scan = y_index + 3;

    % for debugging
    % [x_index, y_index]
    % index = (x_index-1)*width + y_index

    % pixel index in the subimage: pixel_subimage_index
    switch subimage_index_delay % update corresponding pixel_index
        case 1
            pixel_subimage_index1 = pixel_subimage_index1 + uint16(1);
            pixel_subimage_index = pixel_subimage_index1;
            current_state = current_state1;
        case 2
            pixel_subimage_index2 = pixel_subimage_index2 + uint16(1);
            pixel_subimage_index = pixel_subimage_index2;
            current_state = current_state2;
        case 3
            pixel_subimage_index3 = pixel_subimage_index3 + uint16(1);
            pixel_subimage_index = pixel_subimage_index3;
            current_state = current_state3;
        case 4
            pixel_subimage_index4 = pixel_subimage_index4 + uint16(1);
            pixel_subimage_index = pixel_subimage_index4;
            current_state = current_state4;
        case 5
            pixel_subimage_index5 = pixel_subimage_index5 + uint16(1);
            pixel_subimage_index = pixel_subimage_index5;
            current_state = current_state5;
        case 6
            pixel_subimage_index6 = pixel_subimage_index6 + uint16(1);
            pixel_subimage_index = pixel_subimage_index6;
            current_state = current_state6;
        case 7
            pixel_subimage_index7 = pixel_subimage_index7 + uint16(1);
            pixel_subimage_index = pixel_subimage_index7;
            current_state = current_state7;
        case 8
            pixel_subimage_index8 = pixel_subimage_index8 + uint16(1);
            pixel_subimage_index = pixel_subimage_index8;
            current_state = current_state8;
        case 9
            pixel_subimage_index9 = pixel_subimage_index9 + uint16(1);
            pixel_subimage_index = pixel_subimage_index9;
            current_state = current_state9;
        otherwise
            pixel_subimage_index = uint16(0);
            current_state = S0;

    end

    % context calculation (int8)
    % simplification: zero paddings
    x = int8(a3_value); %x = fi(a3_value,1,8,0);
    a = int8(d3_value); %a0 = fi(d3_value,1,8,0);
    b = int8(a6_value); %b0 = fi(a6_value,1,8,0);
    c = int8(d6_value); %c0 = fi(d6_value,1,8,0);
    d = int8(d0_value); %d0 = fi(d0_value,1,8,0);
    e = int8(a9_value); %e0 = fi(a9_value,1,8,0);

    %% judge whether go to runlength mode
    g1 = a - c;
    g2 = c - b;
    g3 = d - a;
    g4 = b - e; % compute gradients
    if (current_state == S0)
        if (g1 == g2 && g1 == g3 && g1 == g4 && g1 == 0 && pixel_subimage_index ~= 1)
            current_state = S1; % go to runlength mode
            switch subimage_index_delay % initialize corresponding run_count & run_value
                case 1
                    run_count1 = uint16(0);
                    run_value1 = b;
                case 2
                    run_count2 = uint16(0);
                    run_value2 = b;
                case 3
                    run_count3 = uint16(0);
                    run_value3 = b;
                case 4
                    run_count4 = uint16(0);
                    run_value4 = b;
                case 5
                    run_count5 = uint16(0);
                    run_value5 = b;
                case 6
                    run_count6 = uint16(0);
                    run_value6 = b;
                case 7
                    run_count7 = uint16(0);
                    run_value7 = b;
                case 8
                    run_count8 = uint16(0);
                    run_value8 = b;
                case 9
                    run_count9 = uint16(0);
                    run_value9 = b;
            end
        end
    end

    %% predictive coding
    if (current_state == S0)
        % normal predictive mode (MED predictor)
        upperbound = int16(255);
        lowerbound = int16(0);
        switch subimage_index_delay
            case 1 % intra-prediction
                gq1 = g_quantize(g1);
                gq2 = g_quantize(g2);
                gq3 = g_quantize(g3);
                gq4 = g_quantize(g4);
                switch gq1
                    case uint8(0)
                        gs1 = uint16(0);
                    case uint8(1)
                        gs1 = uint16(125);
                    case uint8(2)
                        gs1 = uint16(250);
                    case uint8(3)
                        gs1 = uint16(375);
                    case uint8(4)
                        gs1 = uint16(500);
                    otherwise
                        gs1 = uint16(0);
                end
                switch gq2
                    case uint8(0)
                        gs2 = uint16(0);
                    case uint8(1)
                        gs2 = uint16(25);
                    case uint8(2)
                        gs2 = uint16(50);
                    case uint8(3)
                        gs2 = uint16(75);
                    case uint8(4)
                        gs2 = uint16(100);
                    otherwise
                        gs2 = uint16(0);
                end
                switch gq3
                    case uint8(0)
                        gs3 = uint16(0);
                    case uint8(1)
                        gs3 = uint16(5);
                    case uint8(2)
                        gs3 = uint16(10);
                    case uint8(3)
                        gs3 = uint16(15);
                    case uint8(4)
                        gs3 = uint16(20);
                    otherwise
                        gs3 = uint16(0);
                end

                % get context index
                context_index = gs1 + gs2 + gs3 + uint16(gq4) + uint16(1);
                %                 residue = find_residue(context_index);
                residue = int8(residue_learned(context_index));
                if residue == int8(7)
                    if (c >= max(b, a))
                        predict_x = min(b, a);
                    elseif (c <= min(b, a))
                        predict_x = max(b, a);
                    else
                        predict_x = b + a - c;
                    end
                else
                    predict_x = b + residue;
                    if predict_x < int8(0)
                        predict_x = int8(0);
                    end
                    if predict_x > int8(7)
                        predict_x = int8(7);
                    end
                end

            case 2 % inter-prediction
                neighbor1 = bitsll(int16(a4_value), 5);
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor1, int16(0));
                predict_x0 = bitsra((upperbound + lowerbound), 1) + int16(-4);
                predict_x0 = uint8(predict_x0);
                predict_x = int8(bitsrl(predict_x0, 5));
            case 3
                neighbor1 = bitsll(int16(a2_value), 5);
                neighbor2 = bitsll(int16(a4_value), 5);
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor1, int16(0));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor2, int16(-4));
                predict_x0 = bitsra((upperbound + lowerbound), 1) + int16(-7);
                predict_x0 = uint8(predict_x0);
                predict_x = int8(bitsrl(predict_x0, 5));
            case 4
                neighbor1 = bitsll(int16(b2_value), 5);
                neighbor2 = bitsll(int16(b4_value), 5);
                neighbor3 = bitsll(int16(b3_value), 5);
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor1, int16(0));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor2, int16(-4));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor3, int16(-7));
                predict_x0 = bitsra((upperbound + lowerbound), 1) + int16(-11);
                predict_x0 = uint8(predict_x0);
                predict_x = int8(bitsrl(predict_x0, 5));
            case 5
                neighbor1 = bitsll(int16(b4_value), 5);
                neighbor2 = bitsll(int16(b3_value), 5);
                neighbor3 = bitsll(int16(b2_value), 5);
                neighbor4 = bitsll(int16(a2_value), 5);
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor1, int16(0));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor2, int16(-4));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor3, int16(-7));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor4, int16(-11));
                predict_x0 = bitsra((upperbound + lowerbound), 1) + int16(-14);
                predict_x0 = uint8(predict_x0);
                predict_x = int8(bitsrl(predict_x0, 5));
            case 6
                neighbor1 = bitsll(int16(b3_value), 5);
                neighbor2 = bitsll(int16(b2_value), 5);
                neighbor3 = bitsll(int16(b4_value), 5);
                neighbor4 = bitsll(int16(a4_value), 5);
                neighbor5 = bitsll(int16(a2_value), 5);
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor1, int16(0));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor2, int16(-4));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor3, int16(-7));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor4, int16(-11));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor5, int16(-14));
                predict_x0 = bitsra((upperbound + lowerbound), 1) + int16(-18);
                predict_x0 = uint8(predict_x0);
                predict_x = int8(bitsrl(predict_x0, 5));
            case 7
                neighbor1 = bitsll(int16(c3_value), 5);
                neighbor2 = bitsll(int16(c2_value), 5);
                neighbor3 = bitsll(int16(c4_value), 5);
                neighbor4 = bitsll(int16(b4_value), 5);
                neighbor5 = bitsll(int16(b2_value), 5);
                neighbor6 = bitsll(int16(b3_value), 5);
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor1, int16(0));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor2, int16(-4));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor3, int16(-7));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor4, int16(-11));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor5, int16(-14));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor6, int16(-18));
                predict_x0 = bitsra((upperbound + lowerbound), 1) + int16(-21);
                predict_x0 = uint8(predict_x0);
                predict_x = int8(bitsrl(predict_x0, 5));
            case 8
                neighbor1 = bitsll(int16(c4_value), 5);
                neighbor2 = bitsll(int16(c3_value), 5);
                neighbor3 = bitsll(int16(c2_value), 5);
                neighbor4 = bitsll(int16(b2_value), 5);
                neighbor5 = bitsll(int16(b3_value), 5);
                neighbor6 = bitsll(int16(b4_value), 5);
                neighbor7 = bitsll(int16(a4_value), 5);
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor1, int16(0));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor2, int16(-4));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor3, int16(-7));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor4, int16(-11));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor5, int16(-14));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor6, int16(-18));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor7, int16(-21));
                predict_x0 = bitsra((upperbound + lowerbound), 1) + int16(-25);
                predict_x0 = uint8(predict_x0);
                predict_x = int8(bitsrl(predict_x0, 5));
            case 9
                neighbor1 = bitsll(int16(c2_value), 5);
                neighbor2 = bitsll(int16(c4_value), 5);
                neighbor3 = bitsll(int16(c3_value), 5);
                neighbor4 = bitsll(int16(b3_value), 5);
                neighbor5 = bitsll(int16(b4_value), 5);
                neighbor6 = bitsll(int16(b2_value), 5);
                neighbor7 = bitsll(int16(a2_value), 5);
                neighbor8 = bitsll(int16(a4_value), 5);
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor1, int16(0));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor2, int16(-4));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor3, int16(-7));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor4, int16(-11));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor5, int16(-14));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor6, int16(-18));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor7, int16(-21));
                [upperbound, lowerbound] = bound_update_scalar(upperbound, lowerbound, neighbor8, int16(-25));
                predict_x0 = bitsra((upperbound + lowerbound), 1) + int16(-28);
                predict_x0 = uint8(predict_x0);
                predict_x = int8(bitsrl(predict_x0, 5));
            otherwise
                predict_x = int8(0);
        end

        if (x_index == 1 || x_index == 2 || x_index == 3) && y_index > 3
            predict_x = e;
        end
        % prediction
        error_value = x - predict_x; % prediction residue
        mapped_error_value = error_mapping_hdl(error_value, predict_x, range); % error mapping

        % Golomb encode
        [bitstream, bitstream_length] = GolombRice_hdl(mapped_error_value);
        bitstream_ready = true;
    end

    %% check end of line for the runlength mode
    switch subimage_index_delay % update run_count and run_value as corresponding value
        case 1
            run_value = run_value1;
        case 2
            run_value = run_value2;
        case 3
            run_value = run_value3;
        case 4
            run_value = run_value4;
        case 5
            run_value = run_value5;
        case 6
            run_value = run_value6;
        case 7
            run_value = run_value7;
        case 8
            run_value = run_value8;
        case 9
            run_value = run_value9;
        otherwise
            run_value = int8(0);
    end
    if (current_state == S1)
        if (y_index + uint32(3) > width)
            if (x == run_value)
                EOL = true; % end of line and runlength mode
            else
                EOL = false; % end of line but with interruption
            end
        else
            EOL = false; % not end of line
        end
    else
        EOL = false; % not runlength mode
    end

    % check whether to continue runlength mode
    if (current_state == S1)
        if (x ~= run_value || EOL)
            if (x == run_value)
                switch subimage_index_delay % update corresponding run_count
                    case 1
                        run_count1 = run_count1 + uint16(1);
                    case 2
                        run_count2 = run_count2 + uint16(1);
                    case 3
                        run_count3 = run_count3 + uint16(1);
                    case 4
                        run_count4 = run_count4 + uint16(1);
                    case 5
                        run_count5 = run_count5 + uint16(1);
                    case 6
                        run_count6 = run_count6 + uint16(1);
                    case 7
                        run_count7 = run_count7 + uint16(1);
                    case 8
                        run_count8 = run_count8 + uint16(1);
                    case 9
                        run_count9 = run_count9 + uint16(1);
                end
                bitstream_temp0 = fi(1, 0, 16, 0);
                bitstream_length0 = uint8(1);
            else
                bitstream_temp0 = fi(0, 0, 16, 0);
                bitstream_length0 = uint8(0);
            end
            current_state = S2; % just out of runlength and go to run coding
        else
            bitstream_temp0 = fi(0, 0, 16, 0);
            bitstream_length0 = uint8(0);
        end
        if (current_state == S1) % dont count run interupt variable
            switch subimage_index_delay % update corresponding run_count
                case 1
                    run_count1 = run_count1 + uint16(1);
                case 2
                    run_count2 = run_count2 + uint16(1);
                case 3
                    run_count3 = run_count3 + uint16(1);
                case 4
                    run_count4 = run_count4 + uint16(1);
                case 5
                    run_count5 = run_count5 + uint16(1);
                case 6
                    run_count6 = run_count6 + uint16(1);
                case 7
                    run_count7 = run_count7 + uint16(1);
                case 8
                    run_count8 = run_count8 + uint16(1);
                case 9
                    run_count9 = run_count9 + uint16(1);
            end
            bitstream = fi(1, 0, 16, 0);
            bitstream_length = uint8(1);
            bitstream_ready = true;
        end
    else
        bitstream_temp0 = fi(0, 0, 16, 0);
        bitstream_length0 = uint8(0);
    end

    %% runlength encoding
    if (current_state == S2)
        % encode runlength
        bitstream_length1 = uint8(1);

        % encode interruption
        if (x ~= run_value)
            if (b == a)
                run_interrupt_type = int8(1); % b==a
            else
                run_interrupt_type = int8(0); % b~=a
            end

            % error prediction
            predict_x = a;
            error_value = x - predict_x;

            % merge context
            mapped_run_error_value = error_mapping_hdl(error_value, predict_x, range) - run_interrupt_type; % error mapping

            % encode the interrupt variable
            [bitstream_temp2, bitstream_length2] = GolombRice_hdl(mapped_run_error_value);
        else
            bitstream_temp2 = fi(0, 0, 16, 0);
            bitstream_length2 = uint8(0);
        end

        if (bitstream_length2 == 0)
            bitstream = bitsll(bitstream_temp0, bitstream_length1);
        else
            bitstream = bitor(bitsll(bitstream_temp0, bitstream_length1+bitstream_length2), bitstream_temp2);
        end
        bitstream_length = bitstream_length0 + bitstream_length1 + bitstream_length2; % maximum length = 10
        bitstream_ready = true;

        current_state = S0; % go back to predictive mode
    end

    %% store the current state
    switch subimage_index_delay
        case 1
            current_state1 = current_state;
        case 2
            current_state2 = current_state;
        case 3
            current_state3 = current_state;
        case 4
            current_state4 = current_state;
        case 5
            current_state5 = current_state;
        case 6
            current_state6 = current_state;
        case 7
            current_state7 = current_state;
        case 8
            current_state8 = current_state;
        case 9
            current_state9 = current_state;
    end
end

bitstream_output = fi(bitstream, 0, 10, 0);
bitstream_length_output = fi(bitstream_length, 0, 4, 0);
subimage_index_output = fi(subimage_index_delay, 0, 4, 0);

% output control signals
hStart_output = hStart;
hEnd_output = hEnd;
vStart_output = vStart;
vEnd_output = vEnd;
valid_output = valid;


end % end of compression_hdl
