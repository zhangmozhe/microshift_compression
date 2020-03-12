% TestMat2Vec Test and example of how to use Mat2Vec
%             This m-file first make a test signal (an AR-1 signal), x,
% then we take an DCT on the test signal, and organize the
% coefficients in a matrix. This matrix is quantized using
% a unifor quantizer with threshold, this gives a matrix of integers, W.
% The entries in W may be ordered into sequences of integers in many
% different ways, and this is done by Mat2Vec. These sequences are
% then Huffman coded by Huff06.
% We also compare this to the JPEGlike way of compressing W, in JPEGlike.m

%----------------------------------------------------------------------
% Copyright (c) 2000.  Karl Skretting.  All rights reserved.
% Hogskolen in Stavanger (Stavanger University), Signal Processing Group
% Mail:  karl.skretting@tn.his.no   Homepage:  http://www.ux.his.no/~karlsk/
% 
% HISTORY:
% Ver. 1.0  21.06.2000  KS: function made
%----------------------------------------------------------------------

clear all;
% first make some data we will use in test
K=16;
L=1280;
Samples=K*L;
rho=0.97; 
randn('state',599);
x=filter(1,[1,-rho],randn(Samples,1));    % an AR-1 signal
x2=dct(reshape(x,K,L));     % DCT transform
m2=max(abs(x2(:)));
ThrF=1;Bins=91;
Del=1.01*m2/(Bins/2-1+ThrF);
W=UniQuant(x2,Del,ThrF*Del,Bins);

% now W is a matrix of integers
% and may be transformed into a number of sequences in different ways
for Method=[0,3,5,11,13]
   xC = Mat2Vec(W, Method, K, L);
   if ~iscell(xC)
      error(['xC is not a cell array.']);
   end
   Wr = Mat2Vec(xC, Method, K, L);
   if iscell(Wr)
      error(['Wr is a cell array.']);
   end
   temp=sum(abs(W(:)-Wr(:)));
   if temp
      disp(['Method=',int2str(Method),' is not correct.']);
   else
      disp(['Method=',int2str(Method),' is correct.']);
   end
   % test entropy of the sequences
   xCno=size(xC,1);
   b=0;
   for i=1:xCno
      t=xC{i};
      S=hist(t,min(t):max(t));
      b=b+entropy(S)*length(t);
   end
   bitrate=b/Samples;
   disp(['Method=',int2str(Method),' gives possible bit rate (0-th entropy) ',...
         num2str(bitrate)]);
   % test actual bit rate using Huff06
   Level=1;
   Speed=0;
   [y, Res] = Huff06(xC, Level, Speed);
   disp(['Method=',int2str(Method),' and Level=',int2str(Level),...
         ' gives actual bit rate ',num2str(length(y)*8/Samples)]);
   Level=8;
   [y, Res] = Huff06(xC, Level, Speed);
   disp(['Method=',int2str(Method),' and Level=',int2str(Level),...
         ' gives actual bit rate ',num2str(length(y)*8/Samples)]);
   xCr = Huff06(y);
   Wr = Mat2Vec(xCr, Method, K, L);
   if iscell(Wr)
      error(['Wr is a cell array.']);
   end
   temp=sum(abs(W(:)-Wr(:)));
   if temp
      disp(['Method=',int2str(Method),' is not correct.']);
   else
      disp(['Method=',int2str(Method),' is still correct.']);
   end
end

% we may compare this to the JPEGlike compression
[yJ,ResJ]=JPEGlike(0,W);
bitrateJ=sum(ResJ([2:4,6:8]))/Samples;
disp(['JPEGlike compression of W',...
      ' gives actual bit rate ',num2str(bitrateJ),...
      ' or ',num2str(length(yJ)*8/Samples)]);


return
