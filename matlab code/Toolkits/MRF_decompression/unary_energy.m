function unary = unary_energy(z, z_clamp, w)
% N_labels * N_sites
LARGE_NUM = 2^12;
N_sites = length(z);
N_labels = 256; % labels start from 1
unary = LARGE_NUM * ones(N_labels, N_sites);

for site_index = 1: N_sites
    if (z_clamp(site_index) >=0)
        lowerbound = z_clamp(site_index);
    else
        lowerbound = 0;
    end
    upperbound = z_clamp(site_index) + w -1;
    
    % labels start from 1
    lowerbound = lowerbound + 1;
    upperbound = upperbound + 1;
    
    unary(lowerbound : upperbound,site_index) = 0;
end

unary = int32(unary);