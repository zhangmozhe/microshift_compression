function xC = Mat2Vec(W, Method, K, L)
% Mat2Vec     Convert an integer matrix to a cell array of vectors,
% several different methods are possible, most of them are non-linear.
% The inverse function is also performed by this function, 
% to use this first argument should be a cell array instead of a matrix.
%
% Examples:
% xC = Mat2Vec(W, Method);           % convert the KxL matrix W to vectors
% xC = Mat2Vec(W, Method, K, L);     % convert the KxL matrix W to vectors
% W = Mat2Vec(xC, Method, K, L);     % convert vectors in xC to a KxL matrix
% ---------------------------------------------------------------------------
% arguments:
%  xC       a cell array of column vectors of integers representing the
%           symbol sequences for matrix W.
%  W        a KxL matrix of integers
%  Method   which method to use when transforming the matrix of quantized 
%           values into one or several vectors of integers. 
%           The methods that only return non-negative integers in xC are
%           marked by a '+', the others also returns negative integers
%           if W contain negative integers.
%           For Method=10,11,14 and 15 we have K=2,4,8,16,32,64, or 128.
%           The legal methods are
%              0    by columns, direct                          1 seq.
%              1    by columns, run + values                    2 seq. 
%              2    by rows, direct                             1 seq.
%              3    by rows, run + values                       2 seq. 
%              4 +  EOB coded (by columns)                      1 seq. 
%              5 +  EOB coded (by columns)                      3 seq. 
%              6 +  by columns, run + values                    2 seq.
%              7 +  by rows, run + values                       2 seq.
%              8    each row, direct                            K seq.
%              9    each row, run + values                    2*K seq. 
%             10    each dyadic subband, direct          log2(2*K)seq.  
%             11    each dyadic subband, run + values  2*log2(2*K)seq. 
%             12 +  each row, direct                            K seq.
%             13 +  each row, run + values                    2*K seq. 
%             14 +  each dyadic subband, direct          log2(2*K)seq.  
%             15 +  each dyadic subband, run + values  2*log2(2*K)seq. 
%  K       size of matrix W, number of rows
%  L       size of matrix W, number of columns
% ---------------------------------------------------------------------------

Mfile='Mat2Vec';
Debug=0;

% check input and output arguments, and assign values to arguments
if (nargin < 2); 
   error([Mfile,': function must have two input arguments, see help.']); 
end
if (nargout ~= 1); 
   error([Mfile,': function must have one output arguments, see help.']); 
end

if (~iscell(W))
   ToSeq=1;    % transform matrix W to xC
   if (nargin < 3); K=size(W,1); end;
   if (nargin < 4); L=size(W,2); end;
else
   ToSeq=0;    % transform cell array xC to W
   xC=W;
   clear W
   if (nargin < 4)
      error([Mfile,': function must have four input arguments, see help.']); 
   end
end

% check given Method
Method=floor(Method);
if Method<0; Method=0; end;
if Method>15; Method=15; end;
% find number of sequences in xC from Method
if     (Method== 0); xCno=1; 
elseif (Method== 1); xCno=2; 
elseif (Method== 2); xCno=1; 
elseif (Method== 3); xCno=2; 
elseif (Method== 4); xCno=1; 
elseif (Method== 5); xCno=3; 
elseif (Method== 6); xCno=2; 
elseif (Method== 7); xCno=2; 
elseif (Method== 8); xCno=K; 
elseif (Method== 9); xCno=2*K; 
elseif (Method==10); xCno=log2(K)+1; 
elseif (Method==11); xCno=2*log2(K)+2; 
elseif (Method==12); xCno=K; 
elseif (Method==13); xCno=2*K; 
elseif (Method==14); xCno=log2(K)+1; 
elseif (Method==15); xCno=2*log2(K)+2; 
else                 xCno=0;             end;
% 
if ToSeq 
   [k,l]=size(W);
   if ((k~=K) | (l~=L))
      error([Mfile,': illegal size of W matrix, see help.']); 
   end
   xC=cell(xCno,1); 
   if sum(Method==[4:7,12:15])
      % make W with only positive values
      W=W*2;
      I=find(W<0);
      W(I)=-W(I)-1;   
   end
else
   temp=length(xC);
   if temp~=xCno
      error([Mfile,': size of xC does not correspond to Method, see help.']); 
   end
   W=zeros(K,L);
end

if Method==0                           % direct by columns
   if ToSeq
      xC{1}=W(:);
   else
      W=reshape(xC{1},K,L);
   end
elseif ((Method==1) | (Method==6))     % runs and values, column by column
   if ToSeq
      I=find(W(:));
      xC{2}=W(I);  % values  
      for i=length(I):(-1):2; I(i)=I(i)-I(i-1); end;
      xC{1}=I-1;    % runs  
   else
      I=xC{1};      % runs  
      I=I+1;
      for i=2:length(I);I(i)=I(i-1)+I(i); end;
      W(I)=xC{2};  % values
   end
end
if Method==2                       % direct by rows
   if ToSeq
      W=W';
      xC{1}=W(:);
      W=W';
   else
      W=reshape(xC{1},L,K)';
   end
end
if ((Method==3) | (Method==7))     % runs and values, row by row
   if ToSeq
      W=W';
      I=find(W(:));
      xC{2}=W(I);  % values  
      for i=length(I):(-1):2; I(i)=I(i)-I(i-1); end;
      xC{1}=I-1;    % runs  
      W=W';
   else
      W=zeros(L,K);
      I=xC{1};      % runs  
      I=I+1;
      for i=2:length(I);I(i)=I(i-1)+I(i); end;
      W(I)=xC{2};  % values
      W=W';
   end
end
if Method==4                       % EOB coded
   if ToSeq
      xC{1}=eob3(W);
   else
      W=eob3(xC{1},K);
   end
end
if Method==5                       % EOB coded, three sequences
   if ToSeq
      [xC{1},xC{2},xC{3}]=eob3(W);
   else
      W=eob3(xC{1},xC{2},xC{3},K);
   end
end
if ((Method==8) | (Method==12))    % each row coded as one sequence
   if ToSeq
      for k=1:K
         xC{k}=W(k,:)';
      end
   else
      for k=1:K
         W(k,:)=xC{k}';
      end
   end
end
if ((Method==9) | (Method==13))    % each row coded as runs and values
   if ToSeq
      for k=1:K
         I=find(W(k,:));
         if length(I)
            xC{2*k}=W(k,I)';    % values  
            for i=length(I):(-1):2; I(i)=I(i)-I(i-1); end;
            xC{2*k-1}=(I-1)';    % runs  
         else
            if Debug
               display('empty sequence.');
            end
            xC{2*k}=[];
            xC{2*k-1}=[];
         end
      end
   else
      for k=1:K
         I=xC{2*k-1};      % runs  
         I=I+1;
         for i=2:length(I);I(i)=I(i-1)+I(i); end;
         W(k,I)=xC{2*k}';  % values
      end
   end
end
if ((Method==10) | (Method==14))   % each subband is coded as one sequence
   if rem(log2(K),1)
      error('Logical error: K is not a power of 2.');
   end
   i1=1;i2=1;
   if ToSeq
      for k=1:(log2(K)+1)
         xC{k}=reshape(W(i1:i2,:),L*(i2-i1+1),1);
         i1=i2+1;
         i2=i2*2;
      end
   else
      for k=1:(log2(K)+1)
         W(i1:i2,:)=reshape(xC{k},i2-i1+1,L);
         i1=i2+1;
         i2=i2*2;
      end
   end
end
if ((Method==11) | (Method==15))   % each subband is coded as runs and values
   if rem(log2(K),1)
      error('Logical error: K is not a power of 2.');
   end
   i1=1;i2=1;
   if ToSeq
      for k=1:(log2(K)+1)
         temp=reshape(W(i1:i2,:),L*(i2-i1+1),1);
         I=find(temp);
         xC{2*k}=(temp(I))';    % values  
         for i=length(I):(-1):2; I(i)=I(i)-I(i-1); end;
         xC{2*k-1}=(I-1)';    % runs  
         i1=i2+1;
         i2=i2*2;
      end
   else
      for k=1:(log2(K)+1)
         I=xC{2*k-1};      % runs  
         I=I+1;
         for i=2:length(I);I(i)=I(i-1)+I(i); end;
         temp=zeros(i2-i1+1,L);
         temp(I)=xC{2*k};         % values
         W(i1:i2,:)=temp;
         i1=i2+1;
         i2=i2*2;
      end
   end
end

if ~ToSeq
   if sum(Method==[4:7,12:15])
      W=W/2;
      I=find(rem(W,1));
      W(I)=-W(I)-0.5;    % make negative values in W appear again
   end
   xC=W;                 % must return with W
end

return

