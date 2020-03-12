function unary = unary_energy_v1(z, z_clamp, distortion_pad, subimage_index, w, sigma, verbose, modulo)
% N_labels * N_sites

if nargin < 7
    verbose = true;
end
if(verbose) 
    disp('Calculating unary term'); 
end

N_sites = length(z);
distortion_vector = distortion_vetorize(distortion_pad,N_sites); % vectors with distortion values
N_labels = 256; % labels start from 1

if modulo
    z_array = repmat(z,1,N_labels)';
    for i = 1:length(z)
        if z(i) >= 0
            continue;
        end
        remain_rows = z(i) + 128;
        z_array((remain_rows + 1):end,i) = z(i) + 256;
    end
else
    z_array = repmat(z_clamp,1,N_labels)';
end
label_array = repmat((1:N_labels)', 1, N_sites);

likelihood = (0.5/w)*(erf((z_array - label_array + w)/sqrt(2 * sigma^2)) - erf((z_array - label_array)/sqrt(2 * sigma^2)));
unary = -log(likelihood);

% unary = zeros(N_labels, N_sites);
% for site_index = 1: N_sites
%     x = z_clamp(site_index) + 1;
%     
%     for label_index = 1: N_labels
%        likelihood = 0.5*(erf((x - label_index + w - 1)/sqrt(2*sigma^2)) ...
%            - erf((x - label_index)/sqrt(2*sigma^2))) + 0.01;
%        unary(label_index, site_index) = -log(likelihood);
%     end
% end

unary(unary > 1e4) = 1e4;
unary = int32(unary * 1000);
unary(unary<0) = 0;

% for progressive reconstruction
mask = zeros(size(distortion_vector)); % mask for received location
mask(distortion_vector<=subimage_index) = 1;
mask_location = find(mask==0);
unary(:,mask_location) = 0;

end


function distortion_vector = distortion_vetorize(distortion_pad,N)
    distortion_vector = double(reshape(distortion_pad,N,1));
    % [0,4,7;18,14,11;21,25,28]
    for i = 1:length(distortion_vector)
        switch distortion_vector(i)
            case 0
                distortion_vector(i) = 1;
            case 4
                distortion_vector(i) = 2;
            case 7
                distortion_vector(i) = 3;
            case 11
                distortion_vector(i) = 4;
            case 14
                distortion_vector(i) = 5;
            case 18
                distortion_vector(i) = 6;
            case 21
                distortion_vector(i) = 7;
            case 25
                distortion_vector(i) = 8;
            case 28
                distortion_vector(i) = 9;
        end
    end
end

