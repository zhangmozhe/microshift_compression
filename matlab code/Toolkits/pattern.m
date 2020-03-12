function [distortion_pad, pattern_pad] = pattern(N, x, y, w, pattern, user_define)
% N: pattern_size
% x: height
% y: width

L = N * N;
if nargin < 5
    pattern = [0, 1, 2, 3, 4, 5, 6, 7, 8];
end
if nargin < 6
    user_define = 0;
end
if isempty(pattern)
    pattern = [0, 1, 2; 3, 4, 5; 6, 7, 8];
end
pad_num = ceil((N - 1)/2);

if user_define
    distortion_pattern = pattern;
else
    distortion_pattern = round(pattern*w/L);
end

distortion_pad = repmat(distortion_pattern, [ceil((x + pad_num * 2)/N), ceil((y + pad_num * 2)/N)]);
pattern_pad = repmat(pattern, [ceil((x + pad_num * 2)/N), ceil((y + pad_num * 2)/N)]);

[x1, y1] = size(distortion_pad);
for i = 1:y1 - (y + pad_num * 2)
    distortion_pad(:, end) = [];
    pattern_pad(:, end) = [];
end
for i = 1:x1 - (x + pad_num * 2)
    distortion_pad(end, :) = [];
    pattern_pad(:, end) = [];
end
