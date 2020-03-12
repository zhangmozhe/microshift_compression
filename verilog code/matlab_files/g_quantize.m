function g_quant = g_quantize(g)
if g == int8(0)
    g_quant = uint8(0);
elseif g == int8(1)
    g_quant = uint8(1);
elseif g == int8(-1)
    g_quant = uint8(2);
elseif g > int8(1)
    g_quant = uint8(3);
elseif g < int8(-1)
    g_quant = uint8(4);
else
    g_quant = uint8(0);
end
end