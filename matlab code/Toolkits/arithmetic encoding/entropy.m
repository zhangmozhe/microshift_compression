function H = entropy(S)
% entropy     Function returns 0th order entropy of a source.
% 
% H = entropy(S)
% S is probability or count of each symbol
% S should be a vector of non-negative numbers.

% Ver. 1.0  09.10.97  Karl Skretting
% Ver. 1.1  25.12.98  KS, Signal Processing Project 1998, english version

if nargin<1
   error('entropy: see help.')
end

N=sum(sum(S));		% if S is probability this is 1
if ((N>0) & (min(S(:))>=0))
   Snz=nonzeros(S);
   H=log2(N)-sum(Snz.*log2(Snz))/N;
else
   H=0;
end

return

