function output = iterative_filter(input, option)
% option = 1 guided image filter
% fast WLS filter

ITER_NUM = 8;
output = cell(1,9);
tic
for i = 1: 9
    disp(['filtering ', num2str(i), 'th', ' result']);
    image = input(i);
    image = uint8(image{1,1});

    if option == 1
        for j = 1: ITER_NUM
            %image = imguidedfilter( uint8(image), 'DegreeOfSmoothing', 1.0);
            image = imguidedfilter( uint8(image), 'DegreeOfSmoothing', 1.0, 'NeighborhoodSize',[7 7]);
        end
    else 
        image = FGS(image, 0.015, 2^2, [], 5, 3);
    end
    output{i} = image; 
end
t_filter = toc;
disp(['filter time = ', num2str(t_filter)])
