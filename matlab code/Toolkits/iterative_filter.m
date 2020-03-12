function output = iterative_filter(input, option)
% option = 1 guided image filter
% fast WLS filter

ITER_NUM = 8;
if strcmp(option, 'guided')
    for j = 1:ITER_NUM
        output = imguidedfilter(uint8(input), 'DegreeOfSmoothing', 1.0, 'NeighborhoodSize', [7, 7]);
    end
else
    output = FGS(input, 0.015, 2^2, [], 5, 3);
end