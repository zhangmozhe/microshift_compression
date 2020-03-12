%% MyTest  
clc;  
clear;  
%  
%%  
S = [64 64];  
Miu = [90,150,190];Sig = [20, 20, 20];  
Im = zeros(S(1),S(2));  
Im(1:21,:) = random('norm',Miu(1),Sig(1),[21,64]);  
Im(22:42,:) = random('norm',Miu(2),Sig(2),[21,64]);  
Im(43:64,:) = random('norm',Miu(3),Sig(3),[22,64]);  
figure,imshow(Im,[]);title('raw image');  
  
Image=reshape(Im,S(1)*S(2),1);  
  
topicNum=3;  
temp = eye(topicNum);  
temp(temp==0) = 2;  
temp(temp==1) = 0;  
SmoothCost = temp;  
  
dataCost=zeros(3,S(1)*S(2));  
for i=1:S(1)*S(2)  
        Pyx=normpdf(Image(i),Miu,Sig);  
        dataCost(:,i) = -log( Pyx./sum(Pyx) );  
end  
  
Neighbors=zeros(S(1)*S(2),S(1)*S(2));  
  
for i=1:S(1)*S(2)  
    if(i+1<=S(1)*S(2))  
        Neighbors(i,i+1)=1;  
    end  
    if(i-1>=1)  
        Neighbors(i,i-1)=1;  
    end  
    if(i+64<=S(1)*S(2))  
        Neighbors(i,i+64)=1;  
    end  
    if(i-64>=1)  
        Neighbors(i,i-64)=1;  
    end  
  
end  
  
h = GCO_Create(S(1)*S(2),3);             % Create new object with NumSites=4, NumLabels=3  
GCO_SetDataCost(h,dataCost);   % Site  3   prefers label 3  
GCO_SetSmoothCost(h,SmoothCost);   %   
GCO_SetNeighbors(h,Neighbors);  
GCO_Expansion(h);                % Compute optimal labeling via alpha-expansion   
Label=GCO_GetLabeling(h);  
[E D Smo] = GCO_ComputeEnergy(h)   % Energy = Data Energy + Smooth Energy  
GCO_Delete(h);                   % Delete the GCoptimization object when finished  
labels=reshape(Label,S(1),S(2));  
figure;imshow(labels,[]);  