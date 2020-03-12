function varargout = eob3(arg1, arg2, arg3, arg4)
% eob3        End Of Block Encoding (or decoding) into (from) three sequences
% The EOB sequence of numbers (x) is splitted into three sequences, 
% (x1, x2, x3), based on previous symbol. The total (x) will have 
% L EOB symbol (EOB is 0) for the rest x is one more than y
% The reason to split into several sequences is that the statistics for
% each sequence will be different and this may be exploited in entropy coding
%
% x = eob3(y);                   % encoding into one sequence
% [x1,x2,x3] = eob3(y);          % encoding into three sequences
% [x,x1,x2,x3] = eob3(y);        % encoding into one sequence and three sequences
% y = eob3(x, N);                % decoding from one sequence
% y = eob3(x1, x2, x3, N);       % decoding from three sequences
% ----------------------------------------------
% arguments:
%   x       - all symbols in the EOB sequence, this sequence may
%             be splitted into the three following sequence
%             length(x)=length(x1)+length(x2)+length(x3)
%   x1      - the first symbol and all symbols succeeding an EOB symbol
%   x2      - all symbols succeeding a symbol representing zero (in x this is 1), 
%             this will never be an EOB symbol (which is 0)
%   x3      - other symbols
%   y       - A matrix, size NxL, of non-negtive integers
%   N       - Length of Block, it is length of column in y, 
% ----------------------------------------------
% Note: Number of input arguments indicate encoding or decoding!

%----------------------------------------------------------------------
% Copyright (c) 1999.  Karl Skretting.  All rights reserved.
% Hogskolen in Stavanger (Stavanger University), Signal Processing Group
% Mail:  karl.skretting@tn.his.no   Homepage:  http://www.ux.his.no/~karlsk/
% 
% HISTORY:
% Ver. 1.0  01.01.99  Karl Skretting, Signal Processing Project 1998
% Ver. 1.1  14.01.99  KS, sort rows of y to get rows with fewest
%                     zeros on the top.
% Ver. 1.2  10.03.99  KS, made eob3 based on c_eob
% Ver. 1.3  21.06.00  KS, some minor changes (and moved to ..\comp\ )
%----------------------------------------------------------------------

SortRows=1;     

% check input and output arguments and assigns values to arguments
if (nargout < 1)
   error('eob3: function must have output arguments, see help.'); 
end

if (nargin == 1)
   Encode=1;Decode=0;
   y=arg1;
   clear arg1
   [N,L] = size(y);
   x=zeros((N+1)*L,1); % this will be large enought
   Lx=0;               % length of x
   if SortRows
      % find the right sorting of the rows in y
      NZrow=sum((y>0).');    % number of Non-zeros in each row
      [temp, order]=sort(-NZrow);
      % must store 'order' first, use EOB to indicate thet the rest
      % of the block is ordered
      n=N;
      while (order(n)==n)
         n=n-1;
         if (n==0); break; end;
      end
      % elements after n is now in right order
      if (n>0)
         x((Lx+1):(Lx+n))=order(1:n);
         Lx=Lx+n+1;
      else
         Lx=Lx+1;
      end
      y=y(order,:);          % rows sorted 
   end  % of SortRows
   for l=1:L
      n=N;
      while (y(n,l)==0)
         n=n-1;
         if (n==0); break; end;
      end
      % n is now elements in block except zeros in the end
      if (n>0)
         x((Lx+1):(Lx+n))=y(1:n,l)+1;
         Lx=Lx+n+1;
      else
         Lx=Lx+1;
      end
   end
   x=x(1:Lx);
   if (nargout > 1)
      % split x into x1, x2 and x3
      x1=zeros(Lx,1);Lx1=0;
      x2=zeros(Lx,1);Lx2=0;
      x3=zeros(Lx,1);Lx3=0;
      state=1;
      for l=1:Lx
         if (state==1); Lx1=Lx1+1;x1(Lx1)=x(l); end;
         if (state==2); Lx2=Lx2+1;x2(Lx2)=x(l); end;
         if (state==3); Lx3=Lx3+1;x3(Lx3)=x(l); end;
         if (x(l)==0); state=1; end;
         if (x(l)==1); state=2; end;
         if (x(l)>1); state=3; end;
      end
      x1=x1(1:Lx1);
      x2=x2(1:Lx2);
      x3=x3(1:Lx3);
      disp(['eob3: Matrix of sixe ',int2str(N),'x',...
            int2str(L),' EOB coded into vectors of length ',...
            int2str(Lx1),', ',int2str(Lx2),' and ',int2str(Lx3)]);
   else
      disp(['eob3: Matrix of sixe ',int2str(N),'x',...
            int2str(L),' EOB coded into vector of length ',int2str(Lx)]);
   end
   % now write output arguments
   if (nargout == 1)
      varargout(1) = {x};
   elseif (nargout == 3)
      varargout(1) = {x1};
      varargout(2) = {x2};
      varargout(3) = {x3};
   elseif (nargout == 4)
      varargout(1) = {x};
      varargout(2) = {x1};
      varargout(3) = {x2};
      varargout(4) = {x3};
   else
      warning('eob3: wrong number of output arguments.'); 
   end
   
else
   % decoding if more than one input argument   
   if (nargin == 2)
      % y = c_eob3(x, N);                % decoding from one sequence
      x=arg1(:);
      N=arg2;
      clear arg1 arg2
   elseif (nargin == 4)
      % y = c_eob3(x1, x2, x3, N);       % decoding from three sequences
      x1=arg1(:);
      x2=arg2(:);
      x3=arg3(:);
      N=arg4;
      clear arg1 arg2 arg3 arg4
      % build x from x1, x2 and x3
      Lx=length(x1)+length(x2)+length(x3);
      x=zeros(Lx,1);
      Lx1=0;Lx2=0;Lx3=0;
      state=1;
      for l=1:Lx
         if (state==1); Lx1=Lx1+1;x(l)=x1(Lx1); end;
         if (state==2); Lx2=Lx2+1;x(l)=x2(Lx2); end;
         if (state==3); Lx3=Lx3+1;x(l)=x3(Lx3); end;
         if (x(l)==0); state=1; end;
         if (x(l)==1); state=2; end;
         if (x(l)>1); state=3; end;
      end
   else
      error('eob3: wrong number of input arguments, see help.'); 
   end
   % now do EOB decoding from sequence x
   L=length(find(x==0));  % number of EOB symbols
   if SortRows; L=L-1; end;
   y=zeros(N,L);
   Lx=0;
   if SortRows
      % first find the order of the rows
      order=1:N;   % the sorted (default) order
      n=0;
      while (x(Lx+n+1)>0); n=n+1; end;
      if (n>N); error('eob3: Logical error, too far between EOB symbols.'); end;
      if (n>0); order(1:n)=x((Lx+1):(Lx+n)); end;
      Lx=Lx+n+1;
   end  % of SortRows
   % then find the y array   
   for l=1:L
      n=0;
      while (x(Lx+n+1)>0); n=n+1; end;
      if (n>N); error('eob3: Logical error, too far between EOB symbols.'); end;
      if (n>0); y(1:n,l)=x((Lx+1):(Lx+n))-1; end;
      Lx=Lx+n+1;
   end
   if SortRows
      [temp,order2]=sort(order);    % use order2 to sort rows back
      y=y(order2,:);   % sort rows back to original order
   end 
   disp(['eob3: vector(s) of length ',...
         int2str(Lx),' EOB decoded into Matrix of sixe ',...
         int2str(N),'x',int2str(L)]);
   % now write output arguments
   if (nargout == 1)
      varargout(1) = {y};
   else
      warning('eob3: wrong number of output arguments.'); 
   end
end

return

