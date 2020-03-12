function neighbors = mrf_neighbors(im, distortion, gamma, verbose, modulo)
%% assmeblePairwise assembles pairwise matrix for im_crop
% NumSites-by-NumSites
% gamma: balance coefficient

beta = 0;
alpha = 0.06;
T = 64;
if(nargin < 4)
    verbose = false;
end
if nargin < 5
   modulo = 0; 
end

sz = size(im);  % size of image
sz = sz(1:2);
N = sz(1)*sz(2);% pixel number
c = size(im,3); % color channels: for grayscale image c=1
Z = double(reshape(im,N,c)); % vectors with color channels
D = double(reshape(distortion,N,1)); % vectors with distortion values
theta.beta = beta;

% for 8-connected
r = zeros(N*8,1); % row
c = zeros(N*8,1); % column
s = zeros(N*8,1); % pairwise energy
if(verbose) 
    disp('Assembling pairwise matrix'); 
end
vector_index = 1; % index
for pixel_index = 1:N
    [x,y] = ind2sub_fast(sz,pixel_index); % find [row, column] from index
    D_current = D(pixel_index);
    
    %8-connectivty
    %pairwise energy for horizonal/vertical pairs
    neighborpixel_index = sub2ind_fast(sz,min(x+1,sz(1)),y);
    D_neighbor = D(neighborpixel_index);
    weight = weight_compensate(D_current,D_neighbor,alpha);
    %s(j) = gamma*1*(m ~= i)*exp(-beta*norm(Z(m,:)-Z(i,:))^2);
    s(vector_index) = gamma* V_connection(1) * V_pairwise(Z(neighborpixel_index,:), Z(pixel_index,:), theta, T, 1, modulo, D_current, D_neighbor)*(neighborpixel_index ~= pixel_index) * weight *1.5;
    c(vector_index) = neighborpixel_index; 
    r(vector_index) = pixel_index;
    vector_index = vector_index+1;
    
    neighborpixel_index = sub2ind_fast(sz,max(x-1,1),y);
    D_neighbor = D(neighborpixel_index);
    weight = weight_compensate(D_current,D_neighbor,alpha);
    s(vector_index) = gamma* V_connection(1) * V_pairwise(Z(neighborpixel_index,:), Z(pixel_index,:), theta, T, 1, modulo, D_current, D_neighbor)*(neighborpixel_index ~= pixel_index) * weight *1.5;
    c(vector_index) = neighborpixel_index; 
    r(vector_index) = pixel_index;
    vector_index = vector_index+1;
    
    neighborpixel_index = sub2ind_fast(sz,x,min(y+1,sz(2)));
    D_neighbor = D(neighborpixel_index);
    weight = weight_compensate(D_current,D_neighbor,alpha);
    s(vector_index) = gamma* V_connection(1) * V_pairwise(Z(neighborpixel_index,:), Z(pixel_index,:), theta, T, 1, modulo, D_current, D_neighbor)*(neighborpixel_index ~= pixel_index) * weight;
    c(vector_index) = neighborpixel_index; 
    r(vector_index) = pixel_index;
    vector_index = vector_index+1;
    
    neighborpixel_index = sub2ind_fast(sz,x,max(y-1,1));
    D_neighbor = D(neighborpixel_index);
    weight = weight_compensate(D_current,D_neighbor,alpha);
    s(vector_index) = gamma* V_connection(1) * V_pairwise(Z(neighborpixel_index,:), Z(pixel_index,:), theta, T, 1, modulo, D_current, D_neighbor)*(neighborpixel_index ~= pixel_index) * weight;
    c(vector_index) = neighborpixel_index; 
    r(vector_index) = pixel_index;
    vector_index = vector_index+1;
    
    
    %pairwise energy for diagonal pairs
    neighborpixel_index = sub2ind_fast(sz,min(x+1,sz(1)),min(y+1,sz(2)));
    D_neighbor = D(neighborpixel_index);
    weight = weight_compensate(D_current,D_neighbor,alpha);
    s(vector_index) = gamma* V_connection(2) * V_pairwise(Z(neighborpixel_index,:), Z(pixel_index,:), theta, T, 1, modulo, D_current, D_neighbor)*(neighborpixel_index ~= pixel_index) * weight / 1.4;
    %s(j) = gamma*1/sqrt(2)*(m ~= i)*exp(-beta*norm(Z(m,:)-Z(i,:))^2);
    c(vector_index) = neighborpixel_index; 
    r(vector_index) = pixel_index;
    vector_index = vector_index+1;
    
    neighborpixel_index = sub2ind_fast(sz,max(x-1,1),max(y-1,1));
    D_neighbor = D(neighborpixel_index);
    weight = weight_compensate(D_current,D_neighbor,alpha);
    s(vector_index) = gamma* V_connection(2) * V_pairwise(Z(neighborpixel_index,:), Z(pixel_index,:), theta, T, 1, modulo, D_current, D_neighbor)*(neighborpixel_index ~= pixel_index) * weight / 1.4;
    c(vector_index) = neighborpixel_index; 
    r(vector_index) = pixel_index;
    vector_index = vector_index+1;
    
    neighborpixel_index = sub2ind_fast(sz,max(x-1,1),min(y+1,sz(2)));
    D_neighbor = D(neighborpixel_index);
    weight = weight_compensate(D_current,D_neighbor,alpha);
    s(vector_index) = gamma* V_connection(2) * V_pairwise(Z(neighborpixel_index,:), Z(pixel_index,:), theta, T, 1, modulo, D_current, D_neighbor)*(neighborpixel_index ~= pixel_index) * weight / 1.4;
    c(vector_index) = neighborpixel_index; 
    r(vector_index) = pixel_index;
    vector_index = vector_index+1;
    
    neighborpixel_index = sub2ind_fast(sz,min(x+1,sz(1)),max(y-1,1));
    D_neighbor = D(neighborpixel_index);
    weight = weight_compensate(D_current,D_neighbor,alpha);
    s(vector_index) = gamma* V_connection(2) * V_pairwise(Z(neighborpixel_index,:), Z(pixel_index,:), theta, T, 1, modulo, D_current, D_neighbor)*(neighborpixel_index ~= pixel_index) * weight / 1.4;
    c(vector_index) = neighborpixel_index; 
    r(vector_index) = pixel_index;
    vector_index = vector_index+1;
    
end

neighbors = sparse(r,c,fix(s),N,N);
neighbors(neighbors==2)=1;
neighbors = triu(neighbors);
if(verbose) 
    disp('done'); 
end

end