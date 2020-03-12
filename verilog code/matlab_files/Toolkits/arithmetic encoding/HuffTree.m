function Htree = HuffTree(HL,HK)
% HuffTree    Make the Huffman-tree from the lengths of the Huffman codes
% The Huffman codes are also needed, and if they are known
% they can be given as an extra input argument
%
% Htree = HuffTree(HL,HK);
% Htree = HuffTree(HL);
% ------------------------------------------------------------------
% Arguments:
%  HL     length (bits) for the codeword for each symbol 
%         This is usually found by the hufflen function
%  HK     The Huffman codewords, a matrix of ones or zeros
%         the code for each symbol is a row in the matrix
%  Htree  A matrix, (N*2)x3, representing the Huffman tree, 
%         needed for decoding. Start of tree, root, is Htree(1,:).
%         Htree(i,1)==1 indicate leaf and Htree(i,1)==0 indicate branch
%         Htree(i,2) points to node for left tree if branching point and
%         symbol number if leaf. Note value is one less than symbol number.
%         Htree(i,3) points to node for right tree if branching point
%         Left tree is '0' and right tree is '1'
% ------------------------------------------------------------------

%----------------------------------------------------------------------
% Copyright (c) 1999.  Karl Skretting.  All rights reserved.
% Hogskolen in Stavanger (Stavanger University), Signal Processing Group
% Mail:  karl.skretting@tn.his.no   Homepage:  http://www.ux.his.no/~karlsk/
% 
% HISTORY:
% Ver. 1.0  25.08.98  KS: Function made as part of Signal Compression Project 98
% Ver. 1.1  25.12.98  English version of program
%----------------------------------------------------------------------

if nargin<1
   error('hufftree: see help.');
end
if nargin<2
  HK = HuffCode(HL);
end
N=length(HL);       % number of symbols

Htree=zeros(N*2,3);
root=1;
next=2;
for n=1:N
   if HL(n)>0
      % place this symbol correct in Htree
      pos=root;
      for k=1:HL(n)
         if ((Htree(pos,1)==0) & (Htree(pos,2)==0)) 
            % it's a branching point but yet not activated
            Htree(pos,2)=next;
            Htree(pos,3)=next+1;
            next=next+2;
         end
         if HK(n,k)
            pos=Htree(pos,3);     % goto right branch
         else
            pos=Htree(pos,2);      % goto left branch 
         end
      end
      Htree(pos,1)=1;   % now the position is a leaf
      Htree(pos,2)=n;   % and this is the symbol number it represent  
   end
end
if N==1
   Htree(1,3)=2;
end

return   
      
