function output=Interpolation_cal(input,pattern_index)
if nargin<2
    input=imread('input.bmp');
    input=rgb2gray(input);
    pattern_index=1;
end
[height,width]=size(input);

% Index_sequence{1}=[1,1];
% Index_sequence{2}=[1,1;1,2];
% Index_sequence{3}=[1,1;1,2;1,3];
% Index_sequence{4}=[1,1;1,2;1,3;2,3];
% Index_sequence{5}=[1,1;1,2;1,3;2,3;2,2];
% Index_sequence{6}=[1,1;1,2;1,3;2,3;2,2;2,1];
% Index_sequence{7}=[1,1;1,2;1,3;2,3;2,2;2,1;3,1];
% Index_sequence{8}=[1,1;1,2;1,3;2,3;2,2;2,1;3,1;3,2];
Index_sequence=[1,1;1,2;1,3;2,3;2,2;2,1;3,1;3,2;3,3];

for index=pattern_index+1:9
    m=Index_sequence(index,1);
    n=Index_sequence(index,2);
    % for each pixel for the whole image
    for px=m:3:height
        for py=n:3:width
            index_x=px;
            index_y=py;
            neighbor=neighbor_cal(input,index_x,index_y,index);
            input(index_x,index_y)=neighbor;
        end
    end
end
output=input;


% index for NaN elements
%[index_x,index_y]=find(isnan(input));
% interpolation for NaN elements
% for i=1:length(index_x)
%     neighbor=neighbor_cal(input,index_x,index_y);
%     output(index_x,index_y)=neighbor;
% end
end



%% find neighbors for image pixel
function neighbor=neighbor_cal(input,index_x,index_y,index)

% index_x_pattern=mod(index_x,3); %index x in the pattern
% index_y_pattern=mod(index_y,3); %index y in the pattern
% index in the pattern
% switch index_x_pattern
%     case 1
%         switch index_y_pattern
%             case 1
%                 index=1;
%             case 2
%                 index=2;
%             case 3
%                 index=3;
%         end
%     case 2
%         switch index_y_pattern
%             case 1
%                 index=6;
%             case 2
%                 index=5;
%             case 3
%                 index=4;
%         end
%     case 3
%         switch index_y_pattern
%             case 1
%                 index=7;
%             case 2
%                 index=8;
%             case 3
%                 index=9;
%         end
%
% end
if index_x>3 && index_x<size(input,1)-1 && index_y>3 && index_y<size(input,2)-1
    switch index
        case 1
            neighbor=input(index_x,index_y);
        case 2
            neighbor=(2*input(index_x,index_y-1)+input(index_x,index_y+2))/3;
        case 3
            neighbor=(input(index_x,index_y-1)+input(index_x,index_y+1))/2;
        case 4
            neighbor=(2*input(index_x-1,index_y)+input(index_x+2,index_y))/3;
        case 5
            neighbor=(input(index_x-1,index_y)+input(index_x,index_y+1))/2;
        case 6
            neighbor=(input(index_x-1,index_y)+input(index_x,index_y+1)+input(index_x,index_y-1))/3;
        case 7
            neighbor=(input(index_x-1,index_y)+input(index_x+1,index_y))/2;
        case 8
            neighbor=(input(index_x-1,index_y)+input(index_x,index_y-1)+input(index_x+1,index_y))/3;
        case 9
            neighbor=(input(index_x-1,index_y)+input(index_x,index_y-1)+input(index_x,index_y+1)+input(index_x+1,index_y))/4;
    end
else
    switch index
        case 1
            neighbor=input(index_x,index_y);
        case 2
            neighbor=input(index_x,index_y-1);
        case 3
            neighbor=input(index_x,index_y-1);
        case 4
            neighbor=input(index_x-1,index_y);
        case 5
            neighbor=input(index_x,index_y+1);
        case 6
            neighbor=input(index_x,index_y+1);
        case 7
            neighbor=input(index_x-1,index_y);
        case 8
            neighbor=input(index_x,index_y-1);
        case 9
            neighbor=input(index_x,index_y-1);
    end
end
end





