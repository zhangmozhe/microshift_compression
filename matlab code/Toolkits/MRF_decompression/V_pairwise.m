function V = V_pairwise(z_q, z_p, theta, T, type, modulo, D_p, D_q)
% inputs: either a scalar (for grayscale image) or a 1*3 vector (for color image)
% theta: a cell that contains all the coefficients
% if type == 1
%     V = exp(-theta.beta*norm(z_p-z_q));
% else
%     V = exp(-theta.beta*norm(z_p-z_q)^2);
% end

if modulo == 0
    if type == 1
        if abs(z_p - Dp - z_q + D_q) > T
            V = 0;
        else
            V = 1;
        end
    else
        if abs(z_p - Dp - z_q + D_q)^2 > T
            V = 0;
        else
            V = 1;
        end
    end
else
    if z_p < 0
        z_1 = z_p + 256;
    else
        z_1 = z_p;
    end
    if z_q < 0
        z_2 = z_q + 256;
    else
        z_2 = z_q;
    end
    if type == 1
        if abs(z_p - z_q) > T && abs(z_p - z_2) > T && abs(z_1 - z_q) > T
            V = 0;
        else
            V = 1;
        end
    else
        if abs(z_p - z_q)^2 > T && abs(z_p - z_2)^2 > T && abs(z_1 - z_q)^2 > T
            V = 0;
        else
            V = 1;
        end
    end
end


function y = abs(x)
if x < 0
    y = -x;
else
    y = x;
end


