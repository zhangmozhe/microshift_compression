function varargout = JPEGlike(arg1, arg2, arg3)
% JPEGlike    Entropy encoding (or decoding) in a JPEG like manner
% Coding is very similar to sequential Huffman coding as described in
%   William B. Pennebaker, Joan L. Mitchell.
%   JPEG: Still Image Data Compression Standard, chapter 11.1
%   (Van Nostrand Reinhold, New York, USA, 1992, ISBN: 0442012721)
% The number of input arguments decide whether it is encoding or decoding,
% three input argument for decoding, two for encoding.
%
% [y,Res] = JPEGlike(Speed, W);              % encoding  
% y = JPEGlike(Speed, W);                    % encoding  
% W = JPEGlike(y, N, L);                     % decoding  
%----------------------------------------------------------------------
% arguments:
%   W       The quantized values, a matrix where the first row is the
%           DC component and the following rows are the AC components.
%           We assume AC components (rows) are ordered in ascending frequencies.
%  N        Number of rows in W
%  L        Number of columns in W, [N,L]=size(W)
%  Speed    For complete coding set Speed to 0. Set Speed to 1 to cheat 
%           during encoding, y will then be a sequence of zeros only,
%           but it will be of correct length and the other output 
%           arguments will be correct. 
%  y        a column vector of non-negative integers (bytes) representing 
%           the code, 0 <= y(i) <= 255. 
%  Res      The results (encoding only)        for DC part       for AC part
%           Number og symbols:                 Res(1)            Res(5)
%           Bits to store Huffman table (HL):  Res(2)            Res(6)
%           Bits to store Huffman symbols:     Res(3)            Res(7)
%           Bits to store additional bits:     Res(4)            Res(8)
%           The total of bits is then:  sum(Res([2:4,6:8]))
%----------------------------------------------------------------------

% Function needs following m-files: HuffLen, HuffCode, HuffTree

%----------------------------------------------------------------------
% Copyright (c) 1999.  Karl Skretting.  All rights reserved.
% Hogskolen in Stavanger (Stavanger University), Signal Processing Group
% Mail:  karl.skretting@tn.his.no   Homepage:  http://www.ux.his.no/~karlsk/
% 
% HISTORY:
% Ver. 1.0  26.07.99  Karl Skretting, Signal Processing Project 1999
%----------------------------------------------------------------------

global y Byte BitPos Speed 

Mfile='JPEGlike';
Debug=0;

% check input and output arguments, and assign values to arguments
if (nargin < 2); 
   error([Mfile,': function must have input arguments, see help.']); 
end
if (nargout < 1); 
   error([Mfile,': function must have output arguments, see help.']); 
end

if (nargin == 2)
   Encode=1;Decode=0;
   Speed=arg1;
   W=arg2;
   clear arg1 arg2
   [N,L]=size(W);
   if ((length(Speed(:))~=1)); 
      error([Mfile,': Speed argument is not scalar, see help.']); 
   end
   if Speed; Speed=1; end;
elseif (nargin == 3)
   Encode=0;Decode=1;
   y=arg1(:);         % first argument is y
   N=arg2;
   L=arg3;
   clear arg1 arg2 arg3
   if ((length(N(:))~=1)); 
      error([Mfile,': N argument is not scalar, see help.']); 
   end
   if ((length(L(:))~=1)); 
      error([Mfile,': L argument is not scalar, see help.']); 
   end
else
   error([Mfile,': wrong number of arguments, see help.']); 
end

if N<3
   error([Mfile,': N<3 will not work']); 
end

% Encode
if Encode
   Byte=0;BitPos=1;  % ready to write into first position
   Res=zeros(8,1);
   % take the DC component
   DC=[W(1,1),W(1,2:L)-W(1,1:(L-1))];
   DCsym=abs(DC);
   I=find(DCsym);
   DCsym(I)=floor(log2(DCsym(I)))+1;
   Hi=hist(DCsym,0:15);
   HL=HuffLen(Hi);
   % save HL in 8 byte, then DCsym and extra bits in bits
   bits=8*8+sum(HL.*Hi)+sum(DCsym);
   Res(1)=L;Res(2)=8*8;Res(3)=sum(HL.*Hi);Res(4)=sum(DCsym);
   y=zeros(ceil(bits/8),1);
   if Speed
      % advance Byte and BitPos without writing to y
      Byte=Byte+floor(bits/8);
      BitPos=BitPos-mod(bits,8);
      if (BitPos<=0); BitPos=BitPos+8; Byte=Byte+1; end;
   else
      % save HL 
      for j=1:16
         for (i=4:-1:1); PutBit(bitget(HL(j),i)); end;
      end
      HK=HuffCode(HL);
      % save DCsym and extra bits
      for l=1:L
         if Debug
            disp(['Encode:  DCsym(',int2str(l),')=',int2str(DCsym(l)),...
                  '   DC(',int2str(l),')=',int2str(DC(l))]);
         end
         n=DCsym(l)+1;    % symbol number (value 0 is first symbol, symbol 1)
         for k=1:HL(n)
            PutBit(HK(n,k));
         end
         if DCsym(l)        % extra bits
            if (DC(l)>0)    % the sign '1'='+', '0'='-'
               PutBit(1); 
               n=DC(l)-2^(DCsym(l)-1);
            else; 
               PutBit(0); 
               n=DC(l)+2^DCsym(l)-1;
            end;  
            % if Debug; disp(['   n=',int2str(n)]); end;
            for k=(DCsym(l)-1):-1:1
               PutBit(bitget(n,k));
            end
         end
      end
   end
   
   % now take the AC component
   % The symbols are now in range 0-255, where first four bits are RR
   % and last four bits are SS, SS is as DCsym above
   % disp([int2str(Byte),'  ',int2str(BitPos)]);
   AntSym=sum(sum((W(2:(N-1),:)~=0)))+L+floor((N-1)/16)*L; % should be enough
   ACsym=zeros(AntSym,1);
   AC=ACsym;   % the values
   i=0;
   for l=1:L
      RR=0;
      for n=2:N
         if W(n,l)==0
            RR=RR+1;
         else
            while RR>=16
               i=i+1;
               ACsym(i)=240;  % the symbol ZRL
               RR=RR-16;
            end
            i=i+1;
            AC(i)=W(n,l);
            SS=floor(log2(abs(AC(i))))+1;
            ACsym(i)=16*RR+SS;
            RR=0;
         end
      end
      if RR>0; i=i+1; end;       % the EOB symbol
   end
   ACsym=ACsym(1:i);AC=AC(1:i);
   AntSym=i;
   Hi=hist(ACsym,0:255);
   HL=HuffLen(Hi);
   while max(HL)>16
      % this is not good, try to correct it
      disp([Mfile,': Some codewords get length > 16, we try to correct this']);
      I=find(HL>16); 
      Hi(I)=Hi(I)+1;   % increace 'probability' for these symbols
      HL=HuffLen(Hi);
   end
   Hii=hist(HL,0:16);
   % save HL as in chapter 7.8.1
   bits=16*8+sum(Hii(2:17))*8+sum(HL.*Hi)+sum(mod(ACsym,16));
   Res(5)=AntSym;Res(6)=16*8+sum(Hii(2:17))*8;
   Res(7)=sum(HL.*Hi);Res(8)=sum(mod(ACsym,16));
   y=[y;zeros(ceil(bits/8),1)];
   if Speed
      % advance Byte and BitPos without writing to y
      Byte=Byte+floor(bits/8);
      BitPos=BitPos-mod(bits,8);
      if (BitPos<=0); BitPos=BitPos+8; Byte=Byte+1; end;
   else
      % save HL 
      for i=1:16
         for (j=8:-1:1); PutBit(bitget(Hii(i+1),j)); end;
      end
      for i=1:16
         I=find(HL==i);        % find symbols with codeword length i
         I=I-1;                % symbols in range 0:255
         for k=1:Hii(i+1)
            for (j=8:-1:1); PutBit(bitget(I(k),j)); end;
         end
      end
      HK=HuffCode(HL);
      % save ACsym and extra bits
      for i=1:AntSym
         if Debug
            disp(['Encode:  ACsym(',int2str(i),')=',int2str(ACsym(i)),...
                  '   AC(',int2str(i),')=',int2str(AC(i))]);
         end
         n=ACsym(i)+1;    % symbol number (value 0 is first symbol, symbol 1)
         for k=1:HL(n)
            PutBit(HK(n,k));
         end
         SS=mod(ACsym(i),16);
         if SS        % extra bits
            if (AC(i)>0)    % the sign '1'='+', '0'='-'
               PutBit(1); 
               n=AC(i)-2^(SS-1);
            else; 
               PutBit(0); 
               n=AC(i)+2^SS-1;
            end;  
            if Debug; disp(['   n=',int2str(n)]); end;
            for k=(SS-1):-1:1
               PutBit(bitget(n,k));
            end
         end
      end
   end
   
   y=y(1:Byte);   
   varargout(1) = {y};
   if (nargout >= 2); varargout(2) = {Res}; end;

end

% Decode
if Decode
   W=zeros(N,L);
   Byte=0;BitPos=1;  % ready to read from first position
   % first read the HL tab
   HL=zeros(1,16);
   for j=1:16
      for (i=1:4); HL(j)=HL(j)*2+GetBit; end;
   end
   % then the symbols and extra bits
   DCsym=zeros(1,L);
   DC=DCsym;
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
         DCsym(l)=Htree(pos,2)-1;   % value is one less than symbol number
         pos=root;              % start at root again
         % is there extra bits
         if DCsym(l)
            DC(l)=2^(DCsym(l)-1);
            if (~(GetBit)); DC(l)=1-2*DC(l); end;
            if (DCsym(l)>1)
               n=0;
               for i=1:(DCsym(l)-1); n=n*2+GetBit; end;
               DC(l)=DC(l)+n;
            end
         end
         if Debug
            disp(['Decode:  DCsym(',int2str(l),')=',int2str(DCsym(l)),...
                  '   DC(',int2str(l),')=',int2str(DC(l))]);
         end
      end
   end
   W(1,1)=DC(1);
   for l=2:L; W(1,l)=W(1,l-1)+DC(l); end;
   
   % now take the AC component
   % first read the HL tab
   Hii=zeros(16,1);
   % disp([int2str(Byte),'  ',int2str(BitPos)]);
   for j=1:16
      for (i=1:8); Hii(j)=Hii(j)*2+GetBit; end;
   end
   % disp(Hii);
   HL=zeros(1,256);
   for j=1:16
      for k=1:Hii(j)
         n=0;
         for (i=1:8); n=n*2+GetBit; end;
         HL(n+1)=j;
      end
   end
   % disp(HL)
   
   % then the symbols and the extra bits
   AC=0;ACsym=0;
   Htree=HuffTree(HL);
   root=1;pos=root;     
   Finished=0;
   l=1;n=2;
   while ~Finished
      if GetBit
         pos=Htree(pos,3);
      else
         pos=Htree(pos,2);
      end
      if Htree(pos,1)           % we have arrived at a leaf
         ACsym=Htree(pos,2)-1;   % value is one less than symbol number
         pos=root;              % start at root again
         % is there extra bits
         SS=mod(ACsym,16);
         RR=floor(ACsym/16);
         if SS
            AC=2^(SS-1);
            if (~(GetBit)); AC=1-2*AC; end;
            if (SS>1)
               k=0;
               for i=1:(SS-1); k=k*2+GetBit; end;
               AC=AC+k;
            end
         end
         if Debug
            disp(['Decode:  ACsym=',int2str(ACsym),'   AC=',int2str(AC)]);
         end
      % now put value into W (which is zeros initially)
         if SS; n=n+RR; W(n,l)=AC; n=n+1;
         elseif (ACsym==0); l=l+1; n=2;
         elseif (ACsym==240); n=n+16;
         else; error([Mfile,': logical error, unknown symbol decoded.']); end
         if (n>N); l=l+1; n=2; end;
         if (l>L); Finished=1; end;
      end
   end
   varargout(1) = {W};
end

return;


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

% test of function
W=[-7,4,400,-2,0,1;1,0,1,0,-1,3;-1,1,0,0,-1,4;0,0,0,0,-7,8;-6,2,0,0,5,7]
[y,Res] = JPEGlike(0, W);
W2 = JPEGlike(y, 5, 6)


   