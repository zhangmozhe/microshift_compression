function [compression_ratio, compression_ratio_vector] = compression_ratio_calculate(bitcounts, image_dimension)

subimage_num = max(size(bitcounts));
compression_ratio_vector = zeros(subimage_num, 1);
pixelcount = 0;
bitcount = 0;
for image_index = 1:subimage_num
    bitcount = bitcount + bitcounts(image_index);
    pixelcount = pixelcount + image_dimension{image_index}(1) * image_dimension{image_index}(2);
    compression_ratio_vector(image_index) = image_dimension{image_index}(1) * image_dimension{image_index}(2) * 8 / bitcounts(image_index);
end

compression_ratio = pixelcount * 8 / bitcount;