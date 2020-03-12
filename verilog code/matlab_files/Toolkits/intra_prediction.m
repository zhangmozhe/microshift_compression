function predict_x = intra_prediction(a,b,c,d,e,prediction_mode,residue_learned)
if nargin < 4
   prediction_mode = 1; 
end

if prediction_mode == 1
    predict_x = median_predict(a,b,c);
elseif prediction_mode == 2
    g1 = a - c; g2 = c - b; g3 = d - a; g4 = b - e;
    g1 = g_quantize(g1); 
    g2 = g_quantize(g2); 
    g3 = g_quantize(g3); 
    g4 = g_quantize(g4);
    context_index = g1*5^3 + g2*5^2 + g3*5^1 + g4 + 1;
    residue = residue_learned(context_index);
    if isnan(residue)
        predict_x = median_predict(a,b,c);
    else
        predict_x = b + residue;
        if predict_x < 0
            predict_x = 0;
        end
        if predict_x > 7
           predict_x = 7; 
        end
    end
end
end

function predict_x = median_predict(a,b,c)
if(c >= max(b,a))
        predict_x = min(b,a);
    elseif(c <= min(b,a))
        predict_x = max(b,a);
    else
        predict_x = b + a - c;
end
end

function g_quant = g_quantize(g)
if abs(g) == 0
    g_quant = 0;
elseif g == 1
    g_quant = 1;
elseif g == -1
    g_quant = 2;
elseif g > 1
    g_quant = 3;
elseif g < -1
    g_quant = 4;
end
end



