function varargout = Huff06(xC, ArgLevel, ArgSpeed)
% Huff06      Huffman encoder/decoder with (or without) recursive splitting
% Vectors of integers are Huffman encoded, 
% these vectors are collected in a cell array, xC.
% If first argument is a cell array the function do encoding,
% else decoding is done.
%
% [y, Res] = Huff06(xC, Level, Speed);                    % encoding
% y = Huff06(xC);                                         % encoding
% xC = Huff06(y);                                         % decoding
% ------------------------------------------------------------------
% Arguments:
%  y        a column vector of non-negative integers (bytes) representing 
%           the code, 0 <= y(i) <= 255. 
%  Res      a matrix that sum up the results, size is (NumOfX+1)x4
%           one line for each of the input sequences, the columns are
%           Res(:,1) - number of elements in the sequence
%           Res(:,2) - zero-order entropy of the sequence
%           Res(:,3) - bits needed to code the sequence
%           Res(:,4) - bit rate for the sequence, Res(:,3)/Res(:,1)
%           Then the last line is total (which include bits needed to store NumOfX)
%  xC       a cell array of column vectors of integers representing the
%           symbol sequences. (should not be to large integers)
%           If only one sequence is to be coded, we must make the cell array
%           like: xC=cell(2,1); xC{1}=x; % where x is the sequence
%  Level    How many levels of splitting that is allowed, legal values 1-8
%           If Level=1, no further splitting of the sequences will be done
%           and there will be no recursive splitting.
%  Speed    For complete coding set Speed to 0. Set Speed to 1 to cheat 
%           during encoding, y will then be a sequence of zeros only,
%           but it will be of correct length and the other output 
%           arguments will be correct. 
% ------------------------------------------------------------------

% SOME NOTES ON THE FUNCTION
% huff06 depends on other functions for Huffman code, and the functions in this file
%  HuffLen     - find length of codewords (HL)
%  HuffTabLen  - find bits needed to store Huffman table information (HL)
%  HuffCode    - find huffman codewords
%  HuffTree    - find huffman tree

%----------------------------------------------------------------------
% Copyright (c) 1999-2000.  Karl Skretting.  All rights reserved.
% Hogskolen in Stavanger (Stavanger University), Signal Processing Group
% Mail:  karl.skretting@tn.his.no   Homepage:  http://www.ux.his.no/~karlsk/
% 
% HISTORY:
% Ver. 1.0  13.06.2000  KS: Function made based on huff04
% Ver. 1.1  20.06.2000  KS: Handle some more exceptions
% Ver. 1.2  21.06.2000  KS: Handle also negative values
% Ver. 1.3  23.06.2000  KS: Use logarithms for some sequences (line 114)
% Ver. 1.4  31.07.2000  KS: If a sequence has many zeros, Run + Value coding
%   is done. (from line 255 and some more)
% Ver. 1.5  02.08.2000  KS: May have larger integers in PutVLIC and GetVLIC
% Ver. 1.6  18.01.2001  KS: MaxL in line 218 was reduced from 2^16 to 50000.
%   For some sequences we may have length of code word larger than 16, even
%   if probability was larger than 2^(-16). Ex: Hi=[12798,14241,7126,7159,3520,...
%   3512,1857,1799,1089,1092,681,680,424,431,320,304,201,204,115,118,77,83,45,...
%   40,24,26,18,14,4,12,3,3,4,2,2,0,1]', sum(Hi)=58029
% Ver. 1.7  21.08.2001  KS: MaxL in line 218 and 420 must be the same
%   We may now have long code words (also see HuffTabLen.m)
%----------------------------------------------------------------------

global y Byte BitPos Speed Level

Mfile='Huff06';
Debug=0;    % note Debug is defined in EncodeVector and DecodeVector too

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
else
   Encode=1;Decode=0;
   if (nargin < 3); Speed=0; else Speed=ArgSpeed; end;
   if (nargin < 2); Level=8; else Level=ArgLevel; end;
   if ((length(Speed(:))~=1)); 
      error([Mfile,': Speed argument is not scalar, see help.']); 
   end
   if Speed; Speed=1; end;
   if ((length(Level(:))~=1)); 
      error([Mfile,': Level argument is not scalar, see help.']); 
   end
   Level=floor(Level);
   if (Level < 1); Level=1; end;
   if (Level > 8); Level=8; end;
   NumOfX = length(xC);
end
   
if Encode
   Res=zeros(NumOfX,4);
   % initalize the global variables
   y=zeros(10,1);    % put some zeros into y initially
   Byte=0;BitPos=1;  % ready to write into first position
   % start encoding, first write VLIC to give number of sequences
   PutVLIC(NumOfX);
   if Debug
      disp([Mfile,' (Encode): Level=',int2str(Level),'  Speed=',int2str(Speed),...
            '  NumOfX=',int2str(NumOfX)]);
   end
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
      if (minx<0) 
         Negative=1; 
      else 
         Negative=0; 
      end
      if ( (((maxx*4)>L) | (maxx>1023)) & (L>1) & (maxx>minx))  
         % the test for LogCode could be better, I think, (ver. 1.3)
         LogCode=1;    % this could be 0 if LogCode is not wanted
      else
         LogCode=0;
      end
      PutBit(LogCode);
      PutBit(Negative);
      I=find(x);                      % non-zero entries in x
      Sg=(sign(x(I))+1)/2;            % the signs may be needed later, 0/1
      x=abs(x);   
      if LogCode
         xa=x;                        % additional bits
         x(I)=floor(log2(x(I)));
         xa(I)=xa(I)-2.^x(I);
         x(I)=x(I)+1;
      end
      [bits, ent]=EncodeVector(x);   % store the (abs and/or log) values
      if Negative                    % store the signs
         for i=1:length(Sg); PutBit(Sg(i)); end;   
         bits=bits+length(Sg);
         ent=ent+length(Sg)/L;
      end
      if LogCode                     % store the additional bits
         for i=1:L
            for ii=(x(i)-1):(-1):1
               PutBit(bitget(xa(i),ii));
            end
         end
         bits=bits+sum(x)-length(I);
         ent=ent+(sum(x)-length(I))/L;
      end
      if L>0; Res(num,1)=L; else Res(num,1)=1; end;
      Res(num,2)=ent;
      Res(num,3)=bits;
   end
   y=y(1:Byte);   
   varargout(1) = {y};
   if (nargout >= 2) 
      % now calculate results for the total
      if Ltot<1; Ltot=1; end;   % we do not want Ltot to be zero
      Res(NumOfX+1,3)=Byte*8;
      Res(NumOfX+1,1)=Ltot;
      Res(NumOfX+1,2)=sum(Res(1:NumOfX,1).*Res(1:NumOfX,2))/Ltot;
      Res(:,4)=Res(:,3)./Res(:,1);
      varargout(2) = {Res}; 
   end
end

if Decode
   % initalize the global variables, y is set earlier
   Byte=0;BitPos=1;  % ready to read from first position
   NumOfX=GetVLIC;   % first read number of sequences
   if Debug
      disp([Mfile,'(Decode):  NumOfX=',int2str(NumOfX),'  length(y)=',int2str(length(y))]);
   end
   xC=cell(NumOfX,1);
   for num=1:NumOfX
      LogCode=GetBit;
      Negative=GetBit;
      x=DecodeVector;   % get the (abs and/or log) values
      L=length(x);
      I=find(x);
      if Negative
         Sg=zeros(size(I));
         for i=1:length(I); Sg(i)=GetBit; end;   % and the signs   (0/1)
         Sg=Sg*2-1;                              % (-1/1)
      else
         Sg=ones(size(I));                    
      end
      if LogCode          % read additional bits too
         xa=zeros(L,1);
         for i=1:L
            for ii=2:x(i)
               xa(i)=2*xa(i)+GetBit;
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

return     % end of main function, huff06

% the EncodeVector and DecodeVector functions are the ones
% where actual coding is going on.
% This function calls itself recursively
function [bits, ent] = EncodeVector(x, bits, HL, Maxx, Meanx)
global y Byte BitPos Speed Level 
Debug=0;
Level = Level - 1;
MaxL=50000;         % longer sequences is split in the middle
L=length(x);
% first handle some special possible exceptions,
if L==0
   PutBit(0);       % indicate that a sequence is coded
   PutVLIC(L);      % with length 0 (0 is 6 bits)
   PutBit(0);       % 'confirm' this by a '0', Run + Value is indicated by a '1'
   bits=2+6;
   ent=0;
   Level = Level + 1;
   return    % end of EncodeVector
end
if L==1
   PutBit(0);       % indicate that a sequence is coded
   PutVLIC(L);      % with length 1 (6 bits) 
   PutVLIC(x(1));   % containing this integer    
   bits=1+2*6;
   if (x(1)>=16); bits=bits+4; end;
   if (x(1)>=272); bits=bits+4; end;
   if (x(1)>=4368); bits=bits+5; end;
   if (x(1)>=69904); bits=bits+5; end;
   if (x(1)>=1118480); bits=bits+4; end;
   ent=0;
   Level = Level + 1;
   return    % end of EncodeVector
end
if max(x)==min(x)
   PutBit(0);       % indicate that a sequence is coded
   PutVLIC(L);      % with length L
   for i=1:7; PutBit(1); end;   % write end of Huffman Table
   PutVLIC(x(1));   % containing this integer    
   bits=1+6+7+6;      
   if (x(1)>=16); bits=bits+4; end;
   if (x(1)>=272); bits=bits+4; end;
   if (x(1)>=4368); bits=bits+5; end;
   if (x(1)>=69904); bits=bits+5; end;
   if (x(1)>=1118480); bits=bits+4; end;
   if (L>=16); bits=bits+4; end;
   if (L>=272); bits=bits+4; end;
   if (L>=4368); bits=bits+5; end;
   if (L>=69904); bits=bits+5; end;
   if (L>=1118480); bits=bits+4; end;
   ent=0;
   Level = Level + 1;
   return    % end of EncodeVector
end
% here we test if Run + Value coding should be done
I=find(x);   % the non-zero indices of x
if (L/2-length(I))>50
   Maxx=max(x);
   Hi=IntHist(x,0,Maxx);  % find the histogram
   Hinz=nonzeros(Hi);
   ent=log2(L)-sum(Hinz.*log2(Hinz))/L;  % find entropy
   % there are few non-zero indices => Run+Value coding of x
   x2=x(I);  % the values  
   I=[I(:);L+1];   % include length of x
   for i=length(I):(-1):2; I(i)=I(i)-I(i-1); end;
   x1=I-1;   % the runs  
   % code this as an unconditional split (like if L is large)
   if Speed
      Byte=Byte+1;    % since we add 8 bits
   else
      PutBit(0);       % this is idicated like when a sequence 
      PutVLIC(0);      % of length 0 is coded, but we add one extra bit
      PutBit(1);       % Run + Value is indicated by a '1'
   end;
   [bits1, temp] = EncodeVector(x1);
   [bits2, temp] = EncodeVector(x2);
   bits=bits1+bits2+8;
   Level = Level + 1;
   return    % end of EncodeVector
end

if (nargin==1)
   Maxx=max(x);
   Meanx=mean(x);
   Hi=IntHist(x,0,Maxx);  % find the histogram
   Hinz=nonzeros(Hi);
   ent=log2(L)-sum(Hinz.*log2(Hinz))/L;  % find entropy
   HL=HuffLen(Hi);
   HLlen=HuffTabLen(HL);
   % find number of bits to use, store L, HL and x
   bits=6+HLlen+sum(HL.*Hi);
   if (L>=16); bits=bits+4; end;
   if (L>=272); bits=bits+4; end;
   if (L>=4368); bits=bits+5; end;
   if (L>=69904); bits=bits+5; end;
   if (L>=1118480); bits=bits+4; end;
   if Debug
      disp(['bits=',int2str(bits),'  HLlen=',int2str(HLlen),...
         '   HClen=',int2str(sum(HL.*Hi))]);
   end
else                % arguments are given, do not need to be calculated
   ent=0;
end
%
% Here we have: x, bits, L, HL, Maxx, Meanx, ent
if (L>MaxL)   % we split sequence anyway (and the easy way; in the middle)
   L1=ceil(L/2);L2=L-L1;
   x1=x(1:L1);x2=x((L1+1):L);
elseif ((Level > 0) & (L>10))      
   xm=median(x); % median in MatLab is slow, could be calulated faster by using the histogram
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
   % find bits1 and bits2 for x1 and x2
   L1=length(x1);L2=length(x2);
   Maxx1=max(x1);Maxx2=max(x2);
   Meanx1=mean(x1);Meanx2=mean(x2);
   Hi1=IntHist(x1,0,Maxx1);  % find the histogram
   Hi2=IntHist(x2,0,Maxx2);  % find the histogram
   HL1=HuffLen(Hi1);HL2=HuffLen(Hi2);
   HLlen1=HuffTabLen(HL1);
   HLlen2=HuffTabLen(HL2);
   bits1=6+HLlen1+sum(HL1.*Hi1);
   bits2=6+HLlen2+sum(HL2.*Hi2);
   if (L1>=16); bits1=bits1+4; end;
   if (L1>=272); bits1=bits1+4; end;
   if (L1>=4368); bits1=bits1+5; end;
   if (L1>=69904); bits1=bits1+5; end;
   if (L1>=1118480); bits1=bits1+4; end;
   if (L2>=16); bits2=bits2+4; end;
   if (L2>=272); bits2=bits2+4; end;
   if (L2>=4368); bits2=bits2+5; end;
   if (L2>=69904); bits2=bits2+5; end;
   if (L2>=1118480); bits2=bits2+4; end;
else
   bits1=bits;bits2=bits;
end
% Here we may have: x1, bits1, L1, HL1, Maxx1, Meanx1
% and               x2, bits2, L2, HL2, Maxx2, Meanx2
% but at least we have bits1 and bits2  (and bits)
if Debug
   disp(['Level=',int2str(Level),'  bits=',int2str(bits),'  bits1=',int2str(bits1),...
         '  bits2=',int2str(bits2),'  sum=',int2str(bits1+bits2)]);
end

if (L>MaxL)
   if Speed
      BitPos=BitPos-1;
      if (~BitPos); Byte=Byte+1; BitPos=8; end; 
   else
      PutBit(1);       % indicate sequence is splitted into two
   end;
   [bits1, temp] = EncodeVector(x1);
   [bits2, temp] = EncodeVector(x2);
   bits=bits1+bits2+1;
elseif ((bits1+bits2) < bits) 
   if Speed
      BitPos=BitPos-1;
      if (~BitPos); Byte=Byte+1; BitPos=8; end; 
   else
      PutBit(1);       % indicate sequence is splitted into two
   end;
   [bits1, temp] = EncodeVector(x1, bits1, HL1, Maxx1, Meanx1);
   [bits2, temp] = EncodeVector(x2, bits2, HL2, Maxx2, Meanx2);
   bits=bits1+bits2+1;
else
   bits=bits+1;      % this is how many bits we are going to write
   if Debug
      disp(['EncodeVector: Level=',int2str(Level),'  ',int2str(L),...
            ' sybols stored in ',int2str(bits),' bits.']);
   end
   if Speed
      % advance Byte and BitPos without writing to y
      Byte=Byte+floor(bits/8);
      BitPos=BitPos-mod(bits,8);
      if (BitPos<=0); BitPos=BitPos+8; Byte=Byte+1; end;
   else
      % put the bits into y
      StartPos=Byte*8-BitPos;     % control variable
      PutBit(0);       % indicate that a sequence is coded
      PutVLIC(L);       
      PutHuffTab(HL);
      HK=HuffCode(HL);
      for i=1:L;
         n=x(i)+1;    % symbol number (value 0 is first symbol, symbol 1)
         for k=1:HL(n)
            PutBit(HK(n,k));
         end
      end
      % check if one has used as many bits as calculated
      BitsUsed=Byte*8-BitPos-StartPos;
      if (BitsUsed~=bits)
         disp(['L=',int2str(L),'  max(x)=',int2str(max(x)),'  min(x)=',int2str(min(x))]);
         disp(['BitsUsed=',int2str(BitsUsed),'  bits=',int2str(bits)]);
         error(['Huff06-EncodeVector: Logical error, (BitsUsed~=bits).']); 
      end
   end
end
Level = Level + 1;
return    % end of EncodeVector

function x = DecodeVector
global y Byte BitPos
MaxL=50000;      % as in the EncodeVector function (line 216)
if GetBit
   x1=DecodeVector;
   x2=DecodeVector;
   L=length(x1)+length(x2);
   if (L>MaxL)
      x=[x1(:);x2(:)];
   else
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
   end
else
   L=GetVLIC;
   if (L>1)
      x=zeros(L,1);
      HL=GetHuffTab;
      if length(HL)
         Htree=HuffTree(HL);
         root=1;pos=root;     
         l=0;  % number of symbols decoded so far
         while l<L
            if GetBit
               pos=Htree(pos,3);
            else
               pos=Htree(pos,2);
            end
            if Htree(pos,1)           % we have arrived at a leaf
               l=l+1;
               x(l)=Htree(pos,2)-1;   % value is one less than symbol number
               pos=root;              % start at root again
            end
         end
      else     % HL has length 0, that is empty Huffman table
         x=x+GetVLIC;
      end
   elseif L==0
      if GetBit
         % this is a Run + Value coded sequence
         x1=DecodeVector;
         x2=DecodeVector;
         % now build the actual sequence
         I=x1;      % runs  
         I=I+1;
         L=length(I);  % one more than the number of values in x
         for i=2:L;I(i)=I(i-1)+I(i); end;
         x=zeros(I(L)-1,1);
         x(I(1:(L-1)))=x2;  % values
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

% Functions to write and read the Huffman Table Information
% The format is defined in HuffTabLen, we repeat it here
% Function assume that the table information is stored in the following format
%        previous symbol is set to the initial value 2, Prev=2
%        Then we have for each symbol a code word to tell its length 
%         '0'             - same length as previous symbol
%         '10'            - increase length by 1, and 17->1
%         '1100'          - decrease length by 1, and 0->16
%         '11010'         - increase length by 2, and 17->1, 18->2
%         '11011'         - One zero, unused symbol (twice for two zeros)
%         '111xxxx'       - set code length to CL=Prev+x (where 3 <= x <= 14)
%                           and if CL>16; CL=CL-16
%        we have 4 unused 7 bit code words, which we give the meaning
%         '1110000'+4bits - 3-18 zeros
%         '1110001'+8bits - 19-274 zeros, zeros do not change previous value
%         '1110010'+4bits - for CL=17,18,...,32, do not change previous value
%         '1111111'       - End Of Table

function PutHuffTab(HL)
global y Byte BitPos

HL=HL(:);
% if (max(HL) > 32) 
%    disp(['PutHuffTab: To large value in HL, max(HL)=',int2str(max(HL))]); 
% end
% if (min(HL) < 0)
%    disp(['PutHuffTab: To small value in HL, min(HL)=',int2str(min(HL))]); 
% end
Prev=2;
ZeroCount=0;
L=length(HL);

for l=1:L
   if HL(l)==0
      ZeroCount=ZeroCount+1;
   else
      while (ZeroCount > 0)
         if ZeroCount<3
            for i=1:ZeroCount
               PutBit(1);PutBit(1);PutBit(0);PutBit(1);PutBit(1);
            end
            ZeroCount=0; 
         elseif ZeroCount<19 
            PutBit(1);PutBit(1);PutBit(1);PutBit(0);PutBit(0);PutBit(0);PutBit(0);
            for (i=4:-1:1); PutBit(bitget(ZeroCount-3,i)); end;
            ZeroCount=0; 
         elseif ZeroCount<275
            PutBit(1);PutBit(1);PutBit(1);PutBit(0);PutBit(0);PutBit(0);PutBit(1);
            for (i=8:-1:1); PutBit(bitget(ZeroCount-19,i)); end;
            ZeroCount=0; 
         else 
            PutBit(1);PutBit(1);PutBit(1);PutBit(0);PutBit(0);PutBit(0);PutBit(1);
            for (i=8:-1:1); PutBit(1); end;
            ZeroCount=ZeroCount-274; 
         end
      end
      if HL(l)>16
         PutBit(1);PutBit(1);PutBit(1);PutBit(0);PutBit(0);PutBit(1);PutBit(0);
         for (i=4:-1:1); PutBit(bitget(HL(l)-17,i)); end;
      else
         Inc=HL(l)-Prev;
         if Inc<0; Inc=Inc+16; end;
         if (Inc==0) 
            PutBit(0);
         elseif (Inc==1) 
            PutBit(1);PutBit(0);
         elseif (Inc==2) 
            PutBit(1);PutBit(1);PutBit(0);PutBit(1);PutBit(0);
         elseif (Inc==15) 
            PutBit(1);PutBit(1);PutBit(0);PutBit(0);
         else 
            PutBit(1);PutBit(1);PutBit(1);
            for (i=4:-1:1); PutBit(bitget(Inc,i)); end;
         end
         Prev=HL(l);
      end
   end
end
for (i=7:-1:1); PutBit(1); end;       % the EOT codeword

return;  % end of PutHuffTab

function HL=GetHuffTab
global y Byte BitPos

Debug=0;
Prev=2;
ZeroCount=0;
HL=zeros(10000,1);
HLi=0;
EndOfTable=0;

while ~EndOfTable
   if GetBit
      if GetBit
         if GetBit
            Inc=0;
            for (i=1:4); Inc=Inc*2+GetBit; end;
            if Inc==0
               ZeroCount=0;
               for (i=1:4); ZeroCount=ZeroCount*2+GetBit; end;
               HLi=HLi+ZeroCount+3;
            elseif Inc==1
               ZeroCount=0;
               for (i=1:8); ZeroCount=ZeroCount*2+GetBit; end;
               HLi=HLi+ZeroCount+19;
            elseif Inc==2           % HL(l) is large, >16
               HLi=HLi+1;
               HL(HLi)=0;
               for (i=1:4); HL(HLi)=HL(HLi)*2+GetBit; end;
               HL(HLi)=HL(HLi)+17;
            elseif Inc==15
               EndOfTable=1;
            else
               Prev=Prev+Inc;
               if Prev>16; Prev=Prev-16; end;
               HLi=HLi+1;HL(HLi)=Prev;
            end
         else
            if GetBit
               if GetBit
                  HLi=HLi+1;
               else
                  Prev=Prev+2;
                  if Prev>16; Prev=Prev-16; end;
                  HLi=HLi+1;HL(HLi)=Prev;
               end
            else
               Prev=Prev-1;
               if Prev<1; Prev=16; end;
               HLi=HLi+1;HL(HLi)=Prev;
            end
         end
      else
         Prev=Prev+1;
         if Prev>16; Prev=1; end;
         HLi=HLi+1;HL(HLi)=Prev;
      end
   else
      HLi=HLi+1;HL(HLi)=Prev;
   end
end
if HLi>0
   HL=HL(1:HLi);
else
   HL=[];
end

if Debug
   % check if this is a valid Huffman table
   temp=sum(2.^(-nonzeros(HL)));
   if temp ~=1
      error(['GetHuffTab: HL table is no good, temp=',num2str(temp)]);
   end
end

return;  % end of GetHuffTab

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
if (N<0)
   error('Huff06-PutVLIC: Number is negative.'); 
elseif (N<16)
   PutBit(0);PutBit(0);
   for (i=4:-1:1); PutBit(bitget(N,i)); end;
elseif (N<272)
   PutBit(0);PutBit(1);
   N=N-16;
   for (i=8:-1:1); PutBit(bitget(N,i)); end;
elseif (N<4368)
   PutBit(1);PutBit(0);
   N=N-272;
   for (i=12:-1:1); PutBit(bitget(N,i)); end;
elseif (N<69940)
   PutBit(1);PutBit(1);PutBit(0);
   N=N-4368;
   for (i=16:-1:1); PutBit(bitget(N,i)); end;
elseif (N<1118480)
   PutBit(1);PutBit(1);PutBit(1);PutBit(0);
   N=N-69940;
   for (i=20:-1:1); PutBit(bitget(N,i)); end;
elseif (N<17895696)
   PutBit(1);PutBit(1);PutBit(1);PutBit(1);
   N=N-1118480;
   for (i=24:-1:1); PutBit(bitget(N,i)); end;
else
   error('Huff06-PutVLIC: Number is too large.'); 
end
return

function N=GetVLIC
global y Byte BitPos
N=0;
if GetBit
   if GetBit
      if GetBit
         if GetBit
            for (i=1:24); N=N*2+GetBit; end;
            N=N+1118480;
         else
            for (i=1:20); N=N*2+GetBit; end;
            N=N+69940;
         end
      else
         for (i=1:16); N=N*2+GetBit; end;
         N=N+4368;
      end
   else
      for (i=1:12); N=N*2+GetBit; end;
      N=N+272;
   end
else
   if GetBit
      for (i=1:8); N=N*2+GetBit; end;
      N=N+16;
   else
      for (i=1:4); N=N*2+GetBit; end;
   end
end
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
%if (rem(i1,1) | rem(i2,1));   error('Non integers'); end;
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


