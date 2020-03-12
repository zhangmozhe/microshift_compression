function varargout = Arith06(xC)
% Arith06     Arithmetic encoder or decoder 
% Vectors of integers are arithmetic encoded, 
% these vectors are collected in a cell array, xC.
% If first argument is a cell array the function do encoding,
% else decoding is done.
%
% [y, Res] = Arith06(xC);                    % encoding
% y = Arith06(xC);                           % encoding
% xC = Arith06(y);                           % decoding
% ------------------------------------------------------------------
% Arguments:
%  y        a column vector of non-negative integers (bytes) representing 
%           the code, 0 <= y(i) <= 255. 
%  Res      a matrix that sum up the results, size is (NumOfX+1)x4
%           one line for each of the input sequences, the columns are
%           Res(:,1) - number of elements in the sequence
%           Res(:,2) - unused (=0) 
%           Res(:,3) - bits needed to code the sequence
%           Res(:,4) - bit rate for the sequence, Res(:,3)/Res(:,1)
%           Then the last line is total (which include bits needed to store NumOfX)
%  xC       a cell array of column vectors of integers representing the
%           symbol sequences. (should not be to large integers)
%           If only one sequence is to be coded, we must make the cell array
%           like: xC=cell(2,1); xC{1}=x; % where x is the sequence
% ------------------------------------------------------------------
% Note: this routine is extremely slow since it is all Matlab code
% This function do recursive encoding like Huff06.
% An alternative (a perhaps better) aritmethic coder is Arith07,
% which is a more "pure" arithmetic coder

% SOME NOTES ON THE FUNCTION
% The descrition of the encoding algorithm is in 
% chapter 5 of "The Data Compression Book" by Mark Nelson. 
% The actual coding algorithm is practical identical, it is a translation
% from C code to MatLab code, but some differences have been made.
% The system model, T, keep record of the symbols that have been encoded. 
% Based on this table the probabiltity of each symbol is estimated. Probability 
% for symbol m is: (T(m+1)-T(m+2))/T(1)
% The symbols are 0,1,...,M and Escape (M+1), Escape is used to indicate an 
% unused symbol, which is then coded by another table, the Tu table.
% POSSIBLE IMPROVEMENTS
% - better decision wether to split a sequence or not 
% - for long sequences, update frequency table T=floor(T*a)  (ex: 0.2 < a < 0.9)
%   and do this for every La samples (ex: 100 < La < 5000)
%   We must not set any non-zero probabilities to zero during this adaption!!
% - Display some information (so users know something is happening)

%----------------------------------------------------------------------
% Copyright (c) 1999-2001.  Karl Skretting.  All rights reserved.
% Hogskolen in Stavanger (Stavanger University), Signal Processing Group
% Mail:  karl.skretting@tn.his.no   Homepage:  http://www.ux.his.no/~karlsk/
% 
% HISTORY:
% Ver. 1.0  14.04.1999  KS: Function made
% Ver. 2.0  10.04.2001  KS: made function more like Huff06
%----------------------------------------------------------------------

% these global variables are used to read from or write to the compressed sequence
global y Byte BitPos      
% and these are used by the subfunctions for arithmetic coding
global high low range ub hc lc sc K code

Mfile='Arith06';
K=24;  % number of bits to use in integers  (4 <= K <= 24)
Display=1;      % display progress and/or results

% check input and output arguments, and assign values to arguments
if (nargin < 1); 
   error([Mfile,': function must have input arguments, see help.']); 
end
if (nargout < 1); 
   error([Mfile,': function must have output arguments, see help.']); 
end

if (~iscell(xC))
   Encode=0;Decode=1;
   y=xC(:);            % first argument is y
   y=[y;0;0;0;0];      % add some zeros to always have bits available
else
   Encode=1;Decode=0;
   NumOfX = length(xC);
end

Byte=0;BitPos=1;         % ready to read/write into first position
low=0;high=2^K-1;ub=0;   % initialize the coder
code=0;

if Encode
   Res=zeros(NumOfX,4);
   % initalize the global variables
   y=zeros(10,1);    % put some zeros into y initially
   % start encoding, first write VLIC to give number of sequences
   PutVLIC(NumOfX);
   % now encode each sequence continuously
   Ltot=0;
   for num=1:NumOfX
      x=xC{num};
      x=full(x(:));        % make sure x is a non-sparse column vector
      L=length(x);Ltot=Ltot+L;
      y=[y(1:Byte);zeros(50+2*L,1)];  % make more space available in y
      % now find some info about x to better code it
      maxx=max(x);
      minx=min(x);
      rangex=maxx-minx+1;
      if (minx<0) 
         Negative=1; 
         maxx=max(abs(x));
         minx=min(abs(x));
         rangex=maxx-minx+1;
      else 
         Negative=0; 
      end
      if ( (((rangex*4)>L) | (rangex>1023)) & (L>1) & (maxx>minx))  
         LogCode=1;    % this could be 0 if LogCode is not wanted
      else
         LogCode=0;
      end
      PutABit(LogCode);
      PutABit(Negative);
      I=find(x);                      % non-zero entries in x
      Sg=(sign(x(I))+1)/2;            % the signs may be needed later, 0/1
      x=abs(x);   
      if LogCode
         xa=x;                        % additional bits
         x(I)=floor(log2(x(I)));
         xa(I)=xa(I)-2.^x(I);
         x(I)=x(I)+1;
      end
      bits=EncodeVector(x);           % store the (abs and/or log) values
      if Negative                     % store the signs
         for i=1:length(Sg); PutABit(Sg(i)); end;   
         bits=bits+length(Sg);
      end
      if LogCode                     % store the additional bits
         for i=1:L
            for ii=(x(i)-1):(-1):1
               PutABit(bitget(xa(i),ii));
            end
         end
         bits=bits+sum(x)-length(I);
      end
      if L>0; Res(num,1)=L; else Res(num,1)=1; end;
      Res(num,2)=0;
      Res(num,3)=bits;
      if Display
         disp([Mfile,': Sequence ',int2str(num),' of ',int2str(L),' symbols ',...
               'encoded using ',int2str(bits),' bits.']);
      end
   end
   % flush the arithmetic coder
   PutBit(bitget(low,K-1));     
   ub=ub+1;
   while ub>0
      PutBit(~bitget(low,K-1));
      ub=ub-1;
   end
   % flush is finished
   y=y(1:Byte);   
   varargout(1) = {y};
   if (nargout >= 2) 
      % now calculate results for the total
      if Ltot<1; Ltot=1; end;   % we do not want Ltot to be zero
      Res(NumOfX+1,3)=Byte*8;
      Res(NumOfX+1,1)=Ltot;
      Res(NumOfX+1,2)=0;
      Res(:,4)=Res(:,3)./Res(:,1);
      varargout(2) = {Res}; 
   end
end

if Decode
   for k=1:K
      code=code*2;
      code=code+GetBit;   % read bits into code
   end
   NumOfX=GetVLIC;   % first read number of sequences
   xC=cell(NumOfX,1);
   for num=1:NumOfX
      LogCode=GetABit;
      Negative=GetABit;
      x=DecodeVector;   % get the (abs and/or log) values
      L=length(x);
      I=find(x);
      if Negative
         Sg=zeros(size(I));
         for i=1:length(I); Sg(i)=GetABit; end;   % and the signs   (0/1)
         Sg=Sg*2-1;                               % (-1/1)
      else
         Sg=ones(size(I));                    
      end
      if LogCode          % read additional bits too
         xa=zeros(L,1);
         for i=1:L
            for ii=2:x(i)
               xa(i)=2*xa(i)+GetABit;
            end
         end
         x(I)=2.^(x(I)-1);
         x=x+xa;
      end
      x(I)=x(I).*Sg;
      xC{num}=x;
   end
   varargout(1) = {xC}; 
end

return     % end of main function, Arith06
%----------------------------------------------------------------------
%----------------------------------------------------------------------

% ------- The main functions: EncodeVector and DecodeVector ---------------
% the EncodeVector and DecodeVector functions are the ones
% where actual coding is going on.
% These function may call themselves recursively
function bits = EncodeVector(x)
global y Byte BitPos
global high low range ub hc lc sc K code

StartPos=Byte*8-BitPos;     % used for counting bits
L=length(x);
DoSplit=0;
if L>50
   % try to find a good way to decide if sequence should be splitted
   Hi=IntHist(x,min(x),max(x));  % find the histogram
   Hinz=nonzeros(Hi);
   temp=length(Hinz);
   ent=log2(L)-sum(Hinz.*log2(Hinz))/L;  % find entropy
   % find x1 and x2  (that is do the split)
   xm=median(x);       % median in MatLab is slow
   x1=zeros(L,1);x2=zeros(L,1);
   x2(1)=x(1);i1=0;i2=1;
   for i=2:L
      if (x(i-1) <= xm) 
         i1=i1+1; x1(i1)=x(i);
      else
         i2=i2+1; x2(i2)=x(i);
      end
   end
   x1=x1(1:i1);x2=x2(1:i2);
   %
   L1=length(x1);
   Hi=IntHist(x1,min(x1),max(x1));  % find the histogram
   Hinz=nonzeros(Hi);
   ent1=log2(L1)-sum(Hinz.*log2(Hinz))/L1;  % find entropy
   L2=length(x2);
   Hi=IntHist(x2,min(x2),max(x2));  % find the histogram
   Hinz=nonzeros(Hi);
   ent2=log2(L2)-sum(Hinz.*log2(Hinz))/L2;  % find entropy
   % display results
   if 0
   disp(['Arith06-EncodeVector: sequence x is length ',int2str(L),...
         ' entropy ',num2str(ent),' giving bits ',int2str(ceil(L*ent))]);
   disp(['L1=',int2str(L1),' ent1=',num2str(ent1),' bits1=',int2str(ceil(L1*ent1)),...
      ',  L2=',int2str(L2),' ent2=',num2str(ent2),' bits2=',int2str(ceil(L2*ent2))]);
   disp(['Difference is ',int2str(ceil(L*ent-L1*ent1-L2*ent2)),...
         ' and number of symbols is ',int2str(temp)]);
   end
   % decision
   if (L*ent-L1*ent1-L2*ent2)>(temp*5)   
      DoSplit=1;
   end
end

% Handle some special possible exceptions,
if L==0
   PutABit(0);      % indicate that a sequence is coded
   PutVLIC(0);      % with length 0 (0 is 6 bits)
   PutABit(0);      % 'confirm' this by a '0'
   bits=8;
   return    % end of EncodeVector
end
if L==1
   PutABit(0);      % indicate that a sequence is coded
   PutVLIC(1);      % with length 1 (6 bits) 
   PutVLIC(x(1));   % containing this integer    
   EndPos=Byte*8-BitPos;     % used for counting bits
   bits=EndPos-StartPos;
   return    % end of EncodeVector
end
if max(x)==min(x)
   PutABit(0);      % indicate that a sequence is coded
   PutVLIC(0);      % with length 0 (0 is 6 bits)
   PutABit(1);      % 'deny' this by a '1'
   PutVLIC(L);      % actual length is L  
   PutVLIC(x(1));   % all entries containing this integer    
   EndPos=Byte*8-BitPos;     % used for counting bits
   bits=EndPos-StartPos;
   return    % end of EncodeVector
end
% end of specail cases

if DoSplit       % we split by using the median
   PutABit(1);       % indicate this sequence is splitted into two
   bits1=EncodeVector(x1);
   bits2=EncodeVector(x2);
   bits=bits1+bits2+1;
else
   PutABit(0);       % indicate that a sequence is coded
   PutVLIC(L);       % of this length
   M0=min(x);
   if (M0==0)
      PutABit(0);      % indicate that M0==0
   else
      PutABit(1);      % indicate that M0~=0
      PutVLIC(M0);     % some bits for M0
      x=x-M0;          % translate x
   end
   M=max(x);
   PutVLIC(M);         % some bits for M
   % initialize model
   T=[ones(M+2,1);0];
   Tu=flipud((-1:(M+1))');   % (-1) since ESC never is used in Tu context
   % and code the symbols in the sequence x
   for l=1:L
      sc=T(1);
      m=x(l); 
      hc=T(m+1);lc=T(m+2);
      if hc==lc      % unused symbol, code ESC symbol first
         hc=T(M+2);lc=T(M+3);
         EncodeSymbol;      % code escape with T table
         sc=Tu(1);hc=Tu(m+1);lc=Tu(m+2);  % symbol with Tu table
         Tu(1:(m+1))=Tu(1:(m+1))-1;       % update Tu table
      end
      EncodeSymbol;  % code actual symbol with T table (or Tu table)
      % update T table, MUST be identical in EncodeVector and DecodeVector
      T(1:(m+1))=T(1:(m+1))+1; 
      if (rem(l,5000)==0)  
         dT=T(1:(M+2))-T(2:(M+3));
         dT=floor(dT*7/8+1/8);
         for m=(M+2):(-1):1; T(m)=T(m+1)+dT(m); end;
      end
   end
   EndPos=Byte*8-BitPos;     % used for counting bits
   bits=EndPos-StartPos;
end
return    % end of EncodeVector

function x = DecodeVector
global y Byte BitPos
global high low range ub hc lc sc K code

if GetABit
   x1=DecodeVector;
   x2=DecodeVector;
   L=length(x1)+length(x2);
   xm=median([x1;x2]);
   x=zeros(L,1);
   x(1)=x2(1);
   i1=0;i2=1;
   for i=2:L
      if (x(i-1) <= xm) 
         i1=i1+1; x(i)=x1(i1);
      else
         i2=i2+1; x(i)=x2(i2);
      end
   end
else
   L=GetVLIC;
   if (L>1)      % the normal (?) situation
      x=zeros(L,1);
      if GetABit
         M0=GetVLIC;   
      else
         M0=0;
      end
      M=GetVLIC;   
      % initialize model
      T=[ones(M+2,1);0];
      Tu=flipud((-1:(M+1))');   % (-1) since ESC never is used in Tu context
      % and decode the symbols in the sequence x
      for l=1:L
         sc=T(1);
         range=high-low+1;
         count=floor(( (code-low+1)*sc-1 )/range);
         m=2; while (T(m)>count); m=m+1; end; 
         hc=T(m-1);lc=T(m);m=m-2;
         RemoveSymbol;
         if (m>M)     % decoded ESC symbol, find symbol from Tu table
            sc=Tu(1);range=high-low+1;
            count=floor(( (code-low+1)*sc-1 )/range);
            m=2; while (Tu(m)>count); m=m+1; end; 
            hc=Tu(m-1);lc=Tu(m);m=m-2;
            RemoveSymbol;
            Tu(1:(m+1))=Tu(1:(m+1))-1;   % update Tu table
         end
         x(l)=m;
         % update T table, MUST be identical in EncodeVector and DecodeVector
         T(1:(m+1))=T(1:(m+1))+1; 
         if (rem(l,5000)==0)  
            dT=T(1:(M+2))-T(2:(M+3));
            dT=floor(dT*7/8+1/8);
            for m=(M+2):(-1):1; T(m)=T(m+1)+dT(m); end;
         end
      end
      if M0~=0
         x=x+M0;
      end
   elseif L==0
      if GetABit
         % length 0 was not confirmed
         La=GetVLIC;  % actual length
         x=GetVLIC*ones(La,1);
      else
         x=[];    % this was really a length 0 sequence
      end
   elseif L==1
      x=GetVLIC;
   else
      error('DecodeVector: illegal length of sequence.');
   end
end
return    % end of DecodeVector


% ------- Other subroutines ------------------------------------------------

% Functions to write and read a Variable Length Integer Code word
% This is a way of coding non-negative integers that uses fewer 
% bits for small integers than for large ones. The scheme is:
%   '00'   +  4 bit  - integers from 0 to 15
%   '01'   +  8 bit  - integers from 16 to 271
%   '10'   + 12 bit  - integers from 272 to 4367
%   '110'  + 16 bit  - integers from 4368 to 69903
%   '1110' + 20 bit  - integers from 69940 to 1118479
%   '1111' + 24 bit  - integers from 1118480 to 17895695
%   not supported  - integers >= 17895696 (=2^4+2^8+2^12+2^16+2^20+2^24)
function PutVLIC(N)
global y Byte BitPos
global high low range ub hc lc sc K code
if (N<0)
   error('Arith06-PutVLIC: Number is negative.'); 
elseif (N<16)
   PutABit(0);PutABit(0);
   for (i=4:-1:1); PutABit(bitget(N,i)); end;
elseif (N<272)
   PutABit(0);PutABit(1);
   N=N-16;
   for (i=8:-1:1); PutABit(bitget(N,i)); end;
elseif (N<4368)
   PutABit(1);PutABit(0);
   N=N-272;
   for (i=12:-1:1); PutABit(bitget(N,i)); end;
elseif (N<69940)
   PutABit(1);PutABit(1);PutABit(0);
   N=N-4368;
   for (i=16:-1:1); PutABit(bitget(N,i)); end;
elseif (N<1118480)
   PutABit(1);PutABit(1);PutABit(1);PutABit(0);
   N=N-69940;
   for (i=20:-1:1); PutABit(bitget(N,i)); end;
elseif (N<17895696)
   PutABit(1);PutABit(1);PutABit(1);PutABit(1);
   N=N-1118480;
   for (i=24:-1:1); PutABit(bitget(N,i)); end;
else
   error('Arith06-PutVLIC: Number is too large.'); 
end
return

function N=GetVLIC
global y Byte BitPos
global high low range ub hc lc sc K code
N=0;
if GetABit
   if GetABit
      if GetABit
         if GetABit
            for (i=1:24); N=N*2+GetABit; end;
            N=N+1118480;
         else
            for (i=1:20); N=N*2+GetABit; end;
            N=N+69940;
         end
      else
         for (i=1:16); N=N*2+GetABit; end;
         N=N+4368;
      end
   else
      for (i=1:12); N=N*2+GetABit; end;
      N=N+272;
   end
else
   if GetABit
      for (i=1:8); N=N*2+GetABit; end;
      N=N+16;
   else
      for (i=1:4); N=N*2+GetABit; end;
   end
end
return

% Aritmetic coding of a bit, probability is 0.5 for both 1 and 0
function PutABit(Bit)
global y Byte BitPos
global high low range ub hc lc sc K code
sc=2;
if Bit 
   hc=1;lc=0; 
else 
   hc=2;lc=1; 
end
EncodeSymbol;  % code the bit
return
   
function Bit=GetABit
global y Byte BitPos
global high low range ub hc lc sc K code
range=high-low+1;
sc=2;
count=floor(( (code-low+1)*sc-1 )/range);
if (1>count)
   Bit=1;hc=1;lc=0;
else
   Bit=0;hc=2;lc=1;
end
RemoveSymbol;
return;

% The EncodeSymbol function encode a symbol, (correspond to encode_symbol page 149)
function EncodeSymbol
global y Byte BitPos 
global high low range ub hc lc sc K code
range=high-low+1;
high=low+floor(((range*hc)/sc)-1);
low=low+floor((range*lc)/sc);
while 1          % for loop on page 149
   if bitget(high,K)==bitget(low,K)
      PutBit(bitget(high,K));
      while ub > 0
         PutBit(~bitget(high,K));
         ub=ub-1;
      end
   elseif (bitget(low,K-1) & (~bitget(high,K-1)))
      ub=ub+1;
      low=bitset(low,K-1,0);
      high=bitset(high,K-1,1);
   else
      break
   end
   low=bitset(low*2,K+1,0);
   high=bitset(high*2+1,K+1,0);
end
return

% The RemoveSymbol function removes (and fill in new) bits from
% file, y, to code
function RemoveSymbol 
global y Byte BitPos 
global high low range ub hc lc sc K code
range=high-low+1;
high=low+floor(((range*hc)/sc)-1);
low=low+floor((range*lc)/sc);
while 1
   if bitget(high,K)==bitget(low,K)
      % do nothing (shift bits out)
   elseif (bitget(low,K-1) & (~bitget(high,K-1)))
      code=bitset(code,K-1,~bitget(code,K-1));     % switch bit K-1
      low=bitset(low,K-1,0);
      high=bitset(high,K-1,1);
   else
      break
   end
   low=bitset(low*2,K+1,0);
   high=bitset(high*2+1,K+1,0);
   code=bitset(code*2+GetBit,K+1,0);
end
if (low > high); error('low > high'); end;
return

% Functions to write and read a Bit
function PutBit(Bit)
global y Byte BitPos
BitPos=BitPos-1;
if (~BitPos); Byte=Byte+1; BitPos=8; end; 
y(Byte) = bitset(y(Byte),BitPos,Bit);
return
   
function Bit=GetBit
global y Byte BitPos
BitPos=BitPos-1;
if (~BitPos); Byte=Byte+1; BitPos=8; end; 
Bit=bitget(y(Byte),BitPos);
return;
   
% this function is a variant of the standard hist function
function Hi=IntHist(W,i1,i2);
W=W(:);
L=length(W);
Hi=zeros(i2-i1+1,1);
if (i2-i1)>50
   for l=1:L
      i=W(l)-i1+1;
      Hi(i)=Hi(i)+1;
   end
else
   for i=i1:i2
      I=find(W==i);
      Hi(i-i1+1)=length(I);
   end
end
return;
