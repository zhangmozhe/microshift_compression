function HL = HuffLen(S)
% HuffLen     Find the lengths of the Huffman code words
% Based on probability (or number of occurences) of each symbol 
% the length for the Huffman codewords are calculated.
% 
% HL = hufflen(S);
% ------------------------------------------------------------------
% Arguments:
%  S  a vector with number of occurences or probability of each symbol
%     Only positive elements of S are used, zero (or negative)
%     elements get length 0.
%  HL length (bits) for the codeword for each symbol 
% ------------------------------------------------------------------
% Example:
% hufflen([1,0,4,2,0,1])  =>  ans = [3,0,1,2,0,3]
% hufflen([10,40,20,10])  =>  ans = [3,1,2,3]

%----------------------------------------------------------------------
% Copyright (c) 1999.  Karl Skretting.  All rights reserved.
% Hogskolen in Stavanger (Stavanger University), Signal Processing Group
% Mail:  karl.skretting@tn.his.no   Homepage:  http://www.ux.his.no/~karlsk/
% 
% HISTORY:
% Ver. 1.0  28.08.98  KS: Function made as part of Signal Compression Project 98
% Ver. 1.1  25.12.98  English version of program
% Ver. 1.2  28.07.99  Problem when length(S)==1 was corrected
% Ver. 1.3  22.06.00  KS: Some more exceptions handled
%----------------------------------------------------------------------

if nargin<1
   error('HuffLen: see help.')
end
% some checks and exceptions
if (length(S)==0)          % ver 1.2
   warning('HuffLen: Symbol sequence is empty.');   % a warning is appropriate
   HL=0;
   return;
end
I=find(S<0);
S(I)=0;
if (sum(S)==max(S))
   disp('HuffLen: Only one symbol.');   % a message is appropriate
   HL=zeros(size(S));       % no Huffman code is needed
   return;
end

%  Algorithm "explained" in Norwegian:
%   En bygger opp "treet" ved å legge sammen de to nodene som har
%   minst C, C teller hvor mange verdier som er samlet under denne noden
%   De N første i C er bladene, de andre er noder med to andre noder (blad)
%   under seg, men en trenger ikke nøyaktig hvordan treet er under hver node
%   Det en trenger er for hvert blad å vite hvilken node som er øverst
%   i treet den er festet på, dette er lagret i Top, startverdier er her
%   bladet selv (blad ennå ikke samlet i tre)
%   Si er indekser for toppnodene i C, de er sortert etter hvor mange
%   verdier (count) for hver node. Kun Si(1:last) er interessante,
%   siden en kun har "last" trær. (for hver gang hovedløkka kjører
%   samles to trær til et tre, alle blad som hører til hvert av disse
%   trærne før kodeordeslengden, HL, øket med en, og en må oppdatere hvilken
%   node som nå er toppen for dette bladet, Top(I) settes.

HL=zeros(size(S));  
S=S(:);
Ip=find(S>0);       % index of positive elements
Sp=S(Ip);           % the positive elements of S

N=length(Sp);       % elements in Sp vector
HLp=zeros(size(Sp));    
C=[Sp(:);zeros(N-1,1)];  % count or weights for each "tree"
Top=1:N;                 % the "tree" every symbol belongs to
[So,Si]=sort(-Sp);       % Si is indexes for descending symbols
last=N;                  % Number of "trees" now
next=N+1;                % next free element in C 
while (last > 1)
   % the two smallest "trees" are put together
   C(next)=C(Si(last))+C(Si(last-1));
   I=find(Top==Si(last));
   HLp(I)=HLp(I)+1;   % one extra bit added to elements in "tree"
   Top(I)=next;
   I=find(Top==Si(last-1));
   HLp(I)=HLp(I)+1;   % and one extra bit added to elements in "tree"
   Top(I)=next;
   last=last-1;                 
   Si(last)=next;
   next=next+1;
   % Si shall still be indexes for descending symbols or nodes
   count=last-1;
   while ((count> 0) & (C(Si(count+1)) >= C(Si(count))))
      temp=Si(count);
      Si(count)=Si(count+1);
      Si(count+1)=temp;
      count=count-1;
   end
end

HL(Ip)=HLp;
return;

