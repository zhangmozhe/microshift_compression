function [neighbors_temp, distortions_temp, pixel, shift] = pattern_cal(I,distortion_pattern,px,py,w)
    N=3;
    % calculate neighboring range
    px_start=px-1;
    px_end=px+1;
    py_start=py-1;
    py_end=py+1;
    if px_start==0
        px_start=1;
    end
    if py_start==0
        py_start=1;
    end
    if px_end>size(I,1)
        px_end=px_end-1;
    end
    if py_end>size(I,2)
        py_end=py_end-1;
    end
    
    % distortion_pattern
    
%    [x,y]=size(I);
%     distortion_pattern=repmat(pattern_norm,[ceil(x/N),ceil(y/N)]);
    
    neighbors_temp=zeros((py_end-py_start+1)*(px_end-px_start+1),1);
    distortions_temp=zeros((py_end-py_start+1)*(px_end-px_start+1),1);
    k=0;
    NanNumber=0;
    % neighbors and distortions
    for i=px_start:px_end
        for j=py_start:py_end
            if isnan(I(i,j))
                NanNumber=NanNumber+1;
                continue;
            end
            k=k+1;
            neighbors_temp(k)=I(i,j);
            distortions_temp(k)=distortion_pattern(i,j);
        end
    end
    % deselect NaN
    neighbors_temp(end-NanNumber+1:end)=[];
    distortions_temp(end-NanNumber+1:end)=[];
    neighbors_temp=neighbors_temp;
    distortions_temp=distortions_temp*w/9;
    
    % pixel and shift value at present
    pixel = I(px,py);
    shift = distortion_pattern(px,py)*w/9;
end