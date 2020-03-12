% TestHuff    Test and example of how to use Huff06

%----------------------------------------------------------------------
% Copyright (c) 2000.  Karl Skretting.  All rights reserved.
% Hogskolen in Stavanger (Stavanger University), Signal Processing Group
% Mail:  karl.skretting@tn.his.no   Homepage:  http://www.ux.his.no/~karlsk/
% 
% HISTORY:
% Ver. 1.0  20.06.2000  KS: function made
%----------------------------------------------------------------------

clear all;
% first make some data we will use in test
Level=8;
Speed=0;
xC=cell(15,1);
randn('state',0);
if 1                % do not make many values
   xC{1}=zeros(1000,1);
   xC{1}(23:11:990)=floor(10*randn(length(23:11:990),1));
   for k=2:9
      xC{k}=floor(abs(randn(100+100*k,1)*k));
   end
   randn('state',599);
   xC{10}=floor(filter(1,[1,-0.97],randn(2000,1))+0.5);    % an AR-1 signal
   xC{11}=ones(119,1)*7;
   xC{12}=[];
end
xC{13}=[124,131:146,(-100):5:160]';
xC{14}=4351;
% this next sequence gave an error with previous version (Huff04)
xC{15}=[1,39,37,329,294,236,406,114,378,192,159,0,165,9,77,178,225,30,...
         286,3,157,34,185,146,15,218,97,82,281,1103,80,45,96,31,90,10,...
         105,163,19,10,2,73,114,14,42,553,15,412,76,158,379,440,256,71,...
         181,1,36,149,137,55,191,117,124,32,20,0,88,221,8]';

% now we encode this
[y, Res]=Huff06(xC, Level, Speed);
% and decode it
xR=Huff06(y);
for k=1:15
   disp(['Number of bits for sequence ',int2str(k),' is ',int2str(Res(k,3))]);
   if (sum(xR{k}-xC{k}))
      disp(['Sequence no ', int2str(k),' has difference ',int2str(sum(xR{k}-xC{k}))]);
   end
end
disp(['Total number of bits ', int2str(Res(16,3))]);
return;


