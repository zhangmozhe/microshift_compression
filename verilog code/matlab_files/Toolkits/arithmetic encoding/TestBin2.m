function D = TestBin2(L,N)
% TestBin2    Find difference of some coding strategies
%             First arithmetic coding when first storing N 
% (we assume that L is already stored)
% Then a variant of this where the probabilities is modified for
% each new entry in x (the sequence)

%----------------------------------------------------------------------
% Copyright (c) 2001.  Karl Skretting.  All rights reserved.
% Hogskolen in Stavanger (Stavanger University), Signal Processing Group
% Mail:  karl.skretting@tn.his.no   Homepage:  http://www.ux.his.no/~karlsk/
% 
% HISTORY:
% Ver. 1.0  24.05.2001  KS: function made
%----------------------------------------------------------------------

Mfile='TestBin2';
Display=1;      % display progress and/or results

% check input and output arguments, and assign values to arguments
if (nargin < 2); 
   error([Mfile,': function must have input arguments, see help.']); 
end
L=L(:);
N=N(:);
D=zeros(length(L),length(N));

for i=1:length(L)
   for j=1:length(N)
      l=L(i);n=N(j);
      if (n>=l); break; end;
      ba=log2(l+1)+l*log2(l)-n*log2(n)-(l-n)*log2(l-n);
      % bm=Bitm(l,n);
      bme=BitEst(l,n);
      % D(i,j)=bm-bme;
      D(i,j)=ba-bme;
   end
end

return

function b=BitEst(N,N1);
% the estimate is estimate for large values of N and N1
% for "reasonable" arguments the difference is smaller than 0.005
if (N1>(N/2)); N1=N-N1; end;
N0=N-N1;
if (N>1000)
   b=(N+3/2)*log2(N)-(N0+1/2)*log2(N0)-(N1+1/2)*log2(N1)-1.3256;
elseif (N1>20)
   b=(N+3/2)*log2(N)-(N0+1/2)*log2(N0)-(N1+1/2)*log2(N1)-0.020984*log2(log2(N))-1.25708;
else
   b=log2(N+1)+sum(log2(N-(0:(N1-1))))-sum(log2(N1-(0:(N1-1))));  
end
return

function b=Bitm(N,N1);
% the correct values
if (N1>(N/2)); N1=N-N1; end;
N0=N-N1;
b=sum(log2((N+1)-(0:N1)))-sum(log2(N1-(0:(N1-1))));  
return

% this plot show that the savings in bits going from arithmetic coding
% with fixed probabilities to the variant with modified probabilities
% is smaller than 1.35+0.5*log2(n) (except for the smallest values of n)
N5=1:10;L5=20;
D5=TestBin2(L5,N5);
N4=(1:50);L4=100;
D4=TestBin2(L4,N4);
N1=100*(1:50);L1=10000;
D1=TestBin2(L1,N1);
N2=10*(1:50);L2=1000;
D2=TestBin2(L2,N2);
N3=floor(logspace(0,4,100));
D3=0.5*log2(N3)+1.35;
semilogx(N5,D5,N4,D4,N1,D1,N2,D2,N3,D3);
title('TestBin2: bits saved for bm compared with ba.');
ylabel('bits saved');
xlabel('number of ones, n');
text(11,2.4,'length of sequence, l=20');
