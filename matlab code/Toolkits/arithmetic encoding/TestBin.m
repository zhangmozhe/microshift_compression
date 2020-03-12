% TestBin     Test coding of binary sequence
%             We have a sequence of binary symbols (0/1), where the
% probability of a 1 is p1 and the probability of a 0 is p0=1-p1
% Direct arithmetic coding (DAC) of this sequence (p1 is given) is compared to 
% [adaptive arithmetic coding (AAC) and] count down arithmetic coding (CDAC).
% The value we are interested in is the bit rate, which will be a random
% variable depending on the coding method (DAC/AAC/CDAC), 
% the length of the sequence (N), and the probability of a 1 (p1).
% The expectation (and sometimes the distribution) for this random variable
% is interesting.

%----------------------------------------------------------------------
% Copyright (c) 2000.  Karl Skretting.  All rights reserved.
% Hogskolen in Stavanger (Stavanger University), Signal Processing Group
% Mail:  karl.skretting@tn.his.no   Homepage:  http://www.ux.his.no/~karlsk/
% 
% HISTORY:
% Ver. 1.0  14.05.2001  KS: function made
%----------------------------------------------------------------------

clear all;

p1=0.2;
p0=1-p1;
N=100;
% All sequences are possible. N1 is the number of ones, N0 the number of zeros,
% in the sequence of length N. We have N1+N0=N
% we make an example sequence
rand('state',301);
x=floor(rand(N,1)+p1);
I=find(x);
N1=length(I)
N0=N-N1;
% return;

% some different code segments and more or less meaningful comments

% For DAC (p1 is given) the expected bit rate is given by the entropy
ent=-(p0*log2(p0)+p1*log2(p1));
if 1
   % the entropy (or expected bit rate for DAC) is a function of p1
   p=linspace(0.001,0.999,159);
   entp=-((1-p).*log2((1-p))+p.*log2(p));
   figure(1);
   plot(p,entp);
   title('The entropy function');
   xlabel('Probability');
   ylabel('Entropy');
   grid on;
end
% but the bit rate for an actual sequence will depend on the number
% of zeros and ones in the sequence.
% The probability that N1=n depends on p1 and N, P{N1==n}=binopdf(n,N,p1)
% The bit rate given N1 (and N) and p1 is
bits=N1*log2(1/p1)+N0*log2(1/p0);
br=bits/N;
% the pdf for br may be calculated using the binomial probability function
[m,v]=binostat(N,p1);
% we call this punction brpdf, this function will be zero
% except at some (N+1) distict points, these points are
brpdfx=((0:N)*log2(1/p1)+(N:(-1):0)*log2(1/p0))/N;
% we note that these are evenly distributed between min and max
% the step size is: log2((1-p1)/p1)/N and range is log2((1-p1)/p1)
brpdfx=linspace(log2(1/p0),log2(1/p1),N+1);
% and the distribution is the binomial one
brpdf=binopdf(0:N,N,p1);
plot(brpdfx,brpdf);
% form the graph we see that for p1=0.2 the bit rate will probably be between 0.5 and 1
% the mean of this function is the same as the entropy

% the plot for the entropy function may be extended to also display the 
% confidence interval, the range which the actual value is more
% than pc*100% likely to be whitin. Note that this depends on N
if 0
   N=102;           
   pc=0.98;
   pcd=(1-pc)/2;   % equal on both sides
   p=linspace(0.001,0.999,159);
   entp=-((1-p).*log2((1-p))+p.*log2(p));
   e1=p;e2=p;
   if N>100
      % approximate by normal distribution
      t=norminv(pcd,0,1);
      % for p(i), the number of ones will be between e1(i) and e2(i)
      e1=(N*p+t*sqrt(N*(p.*(1-p))));    % could be floor ?
      e2=(N*p-t*sqrt(N*(p.*(1-p))));    % could be ceil ?
      I=find(e1<0); e1(I)=0;
      I=find(e2>N); e2(I)=N;
   else
      for i=1:length(p)
         t=binoinv(pcd,N,p(i));
         t2=binocdf(t,N,p(i));
         t=max([0,t-1]);
         t1=binocdf(t,N,p(i));
         if (t2>t1)
            e1(i)=t+(pcd-t1)/(t2-t1);
         else
            e1(i)=t;
         end
      end
   end
   e1=-(e1.*log2(p)+(N-e1).*log2(1-p))/N;
   e2=fliplr(e1);
   figure(1);
   plot(p,entp,p,e1,p,e2);
   title(['The entropy function with ',num2str(pc*100),' percent intervall (N=',int2str(N),')']);
   xlabel('Probability');
   ylabel('Entropy');
   grid on;
end

% The actual case will usually be that we have a sequence to be coded,
% and we do not know the probability for ones (p1) in the generating process,
% we do not even know if the elements are independent nor if they are
% equally distributed but this latter we assume now.

% A method to code the sequence is to first code the number of ones, as
% before we assume that the length of the sequence N is known, then
% to code N1, 0<= N1 <= N, will need log2(N+1) bits (we simplify and assume
% that all values of N1 have the same probability, which is not true but practical).
% For the first element to be coded we then have P{x(1)==1}=N1/N
% First make a random sequence
N=100;                 % N is a known value
p1=0.2;      % p1 and p0 is (unknown) parameters just used to make the random 
p0=1-p1;     % sequence x
rand('state',301);
x=floor(rand(N,1)+p1);   % x is a random sequence, x(n) is a random variable
I=find(x);
N1=length(I);      % N1 is a random variable (but it will be given in the beginning)
N0=N-N1;           % so is N0
% Let us define some random variables, M(n) n=1:N, where M(n) is number of 
% ones in x(1:n), obviously we will have M(n) <= M(n+1) and M(N)=N1.
% We define an array PM of size Nx(N1+1) where PM(n,n1)=probability{M(n)==(n1-1)}
% We have   PM(n,n1) = P{ M(n)==(n1-1) }
%           PM(1,1)  = P{ M(1)==0 }  = N0/N = 1-N1/N
%           PM(1,2)  = P{ M(1)==1 }  = N1/N
%           PM(1,k)  = P{ M(1)==(k-1) }  = 0   for k>2
% We note that we should have sum(PM(n,:))==1 for n=1:N
%         PM(n,n1+1) = P{ M(n)==n1 }
%                    = P{ M(n-1)==n1 }       * P{ x(n)==0 | M(n-1)==n1) }
%                      + P{ M(n-1)==(n1-1) } * P{ x(n)==1 | M(n-1)==(n1-1) }
%                    = PM(n-1,n1+1) * (1-(N1-n1)/(N-n+1))
%                      + PM(n-1,n1) * (N1-n1+1)/(N-n+1)
PM=zeros(N,N1+1);
PM(1,1)=1-N1/N;
PM(1,2)=N1/N;
for n=2:N
   PM(n,1)=PM(n-1,1)*((N-N1-n+1)/(N-n+1));
   for k=2:(N1+1)
      PM(n,k)=PM(n-1,k)*((N-N1-n+k)/(N-n+1))+PM(n-1,k-1)*(N1-k+2)/(N-n+1);
   end
end

% how many bits will we need to code the sequence x
N=100;                 % N is a known value
p1=0.2;      % p1 and p0 is (unknown) parameters just used to make the random 
p0=1-p1;     % sequence x
btot=0;
LC=200;
b1=zeros(LC,1);
b2=zeros(LC,1);
for count=1:LC
   rand('state',301+count);
   x=floor(rand(N,1)+p1);   % x is a random sequence, x(n) is a random variable
   I=find(x);
   N1=length(I);      % N1 is a random variable (but it will be given in the beginning)
   N0=N-N1;           % so is N0
   bits=log2(N+1);   % to store N1
   onesleft=N1;
   totleft=N;
   for n=1:N
      if x(n)
         bits=bits-log2(onesleft/totleft);
         onesleft=onesleft-1;
      else
         bits=bits-log2(1-onesleft/totleft);
      end
      totleft=totleft-1;
   end
   % disp(['bits needed = ',num2str(bits)]);
   btot=btot+bits;
   b1(count)=bits/N;
   b2(count)=-(N1*log2(p1)+(N-N1)*log2(1-p1))/N;
end
disp(['average bits needed = ',num2str(btot/LC)]);
mean([b1,b2])        % b2 has lower mean
var([b1,b2])         % b1 has often lower variance, for short sequences
max([b1,b2])         % usually max is lowest for b1

N=100;                 % N is a known value
p1=0.1;      % p1 and p0 is (unknown) parameters just used to make the random 
p0=1-p1;     % sequence x
btot=0;
LC=20;
b1=zeros(LC,1);
b2=zeros(LC,1);
rand('state',300);
x=floor(rand(N,1)+p1);   % x is a random sequence, x(n) is a random variable
I=find(x);
N1=length(I);      % N1 is a random variable (but it will be given in the beginning)
N0=N-N1;           % so is N0
% x=[ones(1,N1),zeros(1,N0)];
for count=1:LC
   temp=randn(N,1);
   [temp,I]=sort(temp);
   x=x(I);           % shuffle the sequence
   bits=log2(N+1);   % to store N1
   onesleft=N1;
   totleft=N;
   for n=1:N
      if x(n)
         bits=bits-log2(onesleft/totleft);
         onesleft=onesleft-1;
      else
         bits=bits-log2(1-onesleft/totleft);
      end
      totleft=totleft-1;
   end
   disp(['bits needed = ',num2str(bits)]);
   btot=btot+bits;
   b1(count)=bits/N;
   b2(count)=(log2(N+1)-N1*log2(N1/N)-(N-N1)*log2((N-N1)/N))/N;
end
disp(['average bits needed = ',num2str(btot/LC)]);
mean(b1)
var(b1)
max(b1)
% this shows that for a sequence where length N, and number of ones N1 is
% given the number of bits to code this is predictable


% We set up B1(N,N1) as the number of bits needed to code a binary sequence
% of length N where there is N1 ones. (we code as above, adapting the
% probabilities as we go along, which saves ~3 bits)
% Since the order of the elements in x do not matter we put the ones first
N=10;
N1=1;
N1=min(N1,N-N1);     %  0 <= N1 <= N/2
n=0:(N1-1);
B1=log2(N+1)+sum(log2(N-n))-sum(log2(N1-n));
B1=B1/N;          % bit rate
disp(['B1(',int2str(N),',',int2str(N1),')=',num2str(B1)]);
% while using a fixed probability N1/N will give
B0=(log2(N+1)-N1*log2(N1)-(N-N1)*log2(N-N1))/N+log2(N);
disp(['B0(',int2str(N),',',int2str(N1),')=',num2str(B0)]);
disp(['The difference is ',num2str(N*(B0-B1))]);

% plot of bits saved by using adaptive probability
N=1000
if 1
   if (N<101)
      NN=1:ceil(N/2);
   else
      NN=ceil(linspace(1,N/2,25));
   end
   B1=zeros(size(NN));
   B2=zeros(size(NN));
   for i=1:length(NN)
      N1=NN(i);
      n=0:(N1-1);
      B1(i)=log2(N+1)+sum(log2(N-n))-sum(log2(N1-n));   % bits
      B2(i)=log2(N+1)-N1*log2(N1)-(N-N1)*log2(N-N1)+N*log2(N);  % bits
   end
   figure(1);
   plot(log2(NN),B2-B1);
   title(['Bits saved by adapting probability, N=',int2str(N)]);
   xlabel('Number of ones');
   ylabel('Bits');
   grid on;
end

p1=0.5;
if 1
   NN=[10:10:100,200:100:1000];
   B1=zeros(size(NN));
   B2=zeros(size(NN));
   for i=1:length(NN)
      N=NN(i);
      N1=floor(NN(i)*p1);
      n=0:(N1-1);
      B1(i)=log2(N+1)+sum(log2(N-n))-sum(log2(N1-n));   % bits
      B2(i)=log2(N+1)-N1*log2(N1)-(N-N1)*log2(N-N1)+N*log2(N);  % bits
   end
   figure(1);
   plot(log2(NN),B2-B1);
   title(['Bits saved by adapting probability, p1=',num2str(p1)]);
   xlabel('log2(N)');
   ylabel('Bits');
   grid on;
end


% test of approximation
for N=[50,100,500,1000,5000,10000];
   p=1/2;
   N1=floor(p*N);
   %  first the correct answer
   B1=log2(N+1)+sum(log2(N-(0:(N1-1))))-sum(log2(N1-(0:(N1-1))));   % bits
   %  then the approximation
   N0=N-N1;
   % The teoretic approximation
   % b1est=(N+3/2)*log2(N)-(N0+1/2)*log2(N0)-(N1+1/2)*log2(N1)+s2+...
   %    (1/(N+1/2)+(N+1/2)/(N+1/4)-(N0+1/2)/(N0+1/4)-(N1+1/2)/(N1+1/4)-10)*log2(exp(1));
   disp(['N=',int2str(N),',  N1=',int2str(N1)]);
   b1est=(N+3/2)*log2(N)-(N0+1/2)*log2(N0)-(N1+1/2)*log2(N1)-0.010631*log2(log2(N))-1.28817;
   disp(['  1000*Difference 1 is ',num2str(1000*(B1-b1est))]);
   b2est=(N+3/2)*log2(N)-(N0+1/2)*log2(N0)-(N1+1/2)*log2(N1)-1.3226;
   disp(['  1000*Difference 2 is ',num2str(1000*(B1-b2est))]);
end
% both approximations are well useful
% try to find "optimal coefficients
A=zeros(0,1);b=zeros(0,1);
for N=[50,100,250,500,1000,5000,10000];
   for p=[0.10,0.2,0.3,0.4,0.45,0.5];
      N1=floor(p*N);
      b1=log2(N+1)+sum(log2(N-(0:(N1-1))))-sum(log2(N1-(0:(N1-1))));   % bits
      b2=N*log2(N)-(N-N1)*log2(N-N1)-N1*log2(N1);
      b3=1.5*log2(N)-0.5*log2(N-N1)-0.5*log2(N1);
      % A=[A;[log2(N),log2(N-N1),log2(N1),1]];
      A=[A;1];
      b=[b;b1-b2-b3];
   end
end
x=A\b;
%      log2(N),           log2(N-N1),       log2(N1)           1
% x= 1.48892478527407  -0.49461589408971  -0.49616311290196  -1.29382354586074
% norm(b-A*x) = 0.02512
%      log2(N),           log2(N-N1),       log2(N1)           1
% x= [ 1.5;               -0.5;             -0.5;          -1.32113849612329 ];
% norm(b-A*x) = 0.04150
%     log2(N),  log2(N-N1),  log2(N1),   log2(log2(N)),  1
% x=  1.498973  -0.494827  -0.49623245   -0.0616557     -1.190184   
% norm(b-A*x) = 0.01417

% we should not count the smallest N1
A=zeros(0,2);b=zeros(0,1);
for N=[50,70,100,250,500,750,1000];
   % for p=[0.1,0.2,0.3,0.4,0.45,0.5];
   for p=0.05:0.05:0.5;
      N1=floor(p*N);
      if N1>20
         b1=log2(N+1)+sum(log2(N-(0:(N1-1))))-sum(log2(N1-(0:(N1-1))));   % bits
         b2=N*log2(N)-(N-N1)*log2(N-N1)-N1*log2(N1);
         b3=1.5*log2(N)-0.5*log2(N-N1)-0.5*log2(N1);
         A=[A;[log2(log2(N)),1]];
         b=[b;b1-b2-b3];
      end
   end
end
x=A\b;
%      log2(N),           log2(N-N1),       log2(N1)           1
% x= [ 1.5;               -0.5;             -0.5;          -1.32234151562252 ];
% norm(b-A*x) = 0.03216
% x= [ 1.5;               -0.5;             -0.5;          -1.32298392950550 ];
% norm(b-A*x) = 0.03547      % using more p-values
% x= [ 1.50283174633830   -0.504191846468   -0.49998398295 -1.31180783192693 ];
% norm(b-A*x) = 0.02252      % using more p-values
%     log2(N),  log2(N-N1),  log2(N1),   log2(log2(N)),  1
% x=  1.5;      -0.5;        -0.5;       -0.010631      -1.28817076478349   
% norm(b-A*x) = 0.02134      % using more p-values
% x=  1.509169  -0.50062     -0.49959    -0.069397      -1.18453873231815   
% norm(b-A*x) = 0.00757      % using more p-values

% we should not count the smallest N1
A=zeros(0,5);b=zeros(0,1);
for N=[50,100,250,500,1000,5000,10000];
   % for p=[0.1,0.2,0.3,0.4,0.45,0.5];
   for p=0.05:0.05:0.5;
      N1=floor(p*N);
      if N1>20
         b1=log2(N+1)+sum(log2(N-(0:(N1-1))))-sum(log2(N1-(0:(N1-1))));   % bits
         b2=N*log2(N)-(N-N1)*log2(N-N1)-N1*log2(N1);
         b3=1.5*log2(N)-0.5*log2(N-N1)-0.5*log2(N1);
         A=[A;[log2(N),log2(N-N1),log2(N1),log2(log2(N)),1]];
         % A=[A;[log2(log2(N)),1]];
         b=[b;b1-b2];
      end
   end
end
x=A\b;
%      log2(N),           log2(N-N1),       log2(N1)           1
% x= [ 1.5;               -0.5;             -0.5;          -1.32234151562252 ];
% norm(b-A*x) = 0.03216
% x= [ 1.5;               -0.5;             -0.5;          -1.32298392950550 ];
% norm(b-A*x) = 0.03547      % using more p-values
% x= [ 1.50283174633830   -0.504191846468   -0.49998398295 -1.31180783192693 ];
% norm(b-A*x) = 0.02252      % using more p-values
%     log2(N),  log2(N-N1),  log2(N1),   log2(log2(N)),  1
% x=  1.5;      -0.5;        -0.5;       -0.010631      -1.28817076478349   
% norm(b-A*x) = 0.02134      % using more p-values
% x=  1.509169  -0.50062     -0.49959    -0.069397      -1.18453873231815   
% norm(b-A*x) = 0.00757      % using more p-values

% the very good approximation function could then be
function b=BitEst(N,N1);
if (N1>(N/2)); N1=N-N1; end;
N0=N-N1;
if (N>1000)
   b=(N+3/2)*log2(N)-(N0+1/2)*log2(N0)-(N1+1/2)*log2(N1)-1.3256;
elseif (N1>20)
   b=(N+3/2)*log2(N)-(N0+1/2)*log2(N0)-(N1+1/2)*log2(N1)-0.020984*log2(log2(N))-1.25708;
else
   b=log2(N+1)+sum(log2(N-(0:(N1-1))))-sum(log2(N1-(0:(N1-1))));  
end
return;

% test this   
for N=[50,100,500,1000,5000,10000];
   p=1/2;
   N1=floor(p*N);
   %  first the correct answer
   B1=log2(N+1)+sum(log2(N-(0:(N1-1))))-sum(log2(N1-(0:(N1-1))));   % bits
   %  then the approximation
   if (N1>(N/2)); N1=N-N1; end;
   N0=N-N1;
   if (N>1000)
      b=(N+3/2)*log2(N)-(N0+1/2)*log2(N0)-(N1+1/2)*log2(N1)-1.3256;
   elseif (N1>20)
      b=(N+3/2)*log2(N)-(N0+1/2)*log2(N0)-(N1+1/2)*log2(N1)-0.020984*log2(log2(N))-1.25708;
   else
      b=log2(N+1)+sum(log2(N-(0:(N1-1))))-sum(log2(N1-(0:(N1-1))));  
   end
   % display results
   disp(['N=',int2str(N),',  N1=',int2str(N1),' bits=',num2str(B1),...
      '   approx.bits=',num2str(b)]);
   disp(['  1000*Difference is ',num2str(1000*(B1-b))]);
end

% --------------------------------------------
% Test how a sequence could be split to make more compact (and slower) compression
clear all;
p1=0.42;
p0=1-p1;
ent=-(p0*log2(p0)+p1*log2(p1));
N=300;
% All sequences are possible. N1 is the number of ones, N0 the number of zeros,
% in the sequence of length N. We have N1+N0=N
% we make an example sequence
if 0
   rand('state',301);
   x=floor(rand(N,1)+p1);
   % x=[x';x';x'];   % make this not so much random sequence
   x=x(:);
else
   x1=abs(floor(filter(1,[1,-0.97],randn(1,N))+0.5));    % an AR-1 signal
   x=[bitget(x1,4);bitget(x1,3);bitget(x1,2);bitget(x1,1)];   % split has no effect
   x=[bitget(x1,4),bitget(x1,3),bitget(x1,2),bitget(x1,1)];   % split has effect
   x=x(:);
end
%  a sequence, x, of length N should be coded
N=length(x);
I=find(x);
N1=length(I);
if (N1>(N/2)); N1=N-N1; end;    % then N1 is number of zeros
N0=N-N1;
b=N1*log2(N/N1)+N0*log2(N/N0);
disp(['N=',int2str(N),',  N1=',int2str(N1),',  (e)bits=',num2str(b)]);
% alternative 1, direct
if (N>1000)
   b=(N+3/2)*log2(N)-(N0+1/2)*log2(N0)-(N1+1/2)*log2(N1)-1.3256;
elseif (N1>20)
   b=(N+3/2)*log2(N)-(N0+1/2)*log2(N0)-(N1+1/2)*log2(N1)-0.020984*log2(log2(N))-1.25708;
else
   b=log2(N+1)+sum(log2(N-(0:(N1-1))))-sum(log2(N1-(0:(N1-1))));  
end
disp(['N=',int2str(N),',  N1=',int2str(N1),' N1/N=',num2str(N1/N),' bits=',num2str(b)]);
bits1=b;
% alternativ 2, splitt in 2 sequences 
I=find(x(1:(N-1)));
J=find(x(1:(N-1))==0);
N11=length(I);   
% store N11, 0 <= N11 <= (N-1)
bits2=log2(N);                                    % bits needed to store N11
if N11<(N/2)
   x1=x(I+1);
   x2=[x(1);x(J+1)];
else
   x1=[x(1);x(I+1)];
   x2=x(J+1);
end
Ntemp=N;N1temp=N1;N=length(x1);N1=length(find(x1));N1=min([N1,N-N1]);N0=N-N1;
if (N>1000)
   b=(N+3/2)*log2(N)-(N0+1/2)*log2(N0)-(N1+1/2)*log2(N1)-1.3256;
elseif (N1>20)
   b=(N+3/2)*log2(N)-(N0+1/2)*log2(N0)-(N1+1/2)*log2(N1)-0.020984*log2(log2(N))-1.25708;
else
   b=log2(N+1)+sum(log2(N-(0:(N1-1))))-sum(log2(N1-(0:(N1-1))));  
end
disp(['N=',int2str(N),',  N1=',int2str(N1),' N1/N=',num2str(N1/N),' bits=',num2str(b)]);
N=Ntemp;N1=N1temp;
bits21=b;
Ntemp=N;N1temp=N1;N=length(x2);N1=length(find(x2));N1=min([N1,N-N1]);N0=N-N1;
if (N>1000)
   b=(N+3/2)*log2(N)-(N0+1/2)*log2(N0)-(N1+1/2)*log2(N1)-1.3256;
elseif (N1>20)
   b=(N+3/2)*log2(N)-(N0+1/2)*log2(N0)-(N1+1/2)*log2(N1)-0.020984*log2(log2(N))-1.25708;
else
   b=log2(N+1)+sum(log2(N-(0:(N1-1))))-sum(log2(N1-(0:(N1-1))));  
end
disp(['N=',int2str(N),',  N1=',int2str(N1),' N1/N=',num2str(N1/N),' bits=',num2str(b)]);
N=Ntemp;N1=N1temp;
bits22=b;
bits2=bits2+bits21+bits22;
% we must also indicate which method used
bits1=bits1+0.415;       % probability 3/4
bits2=bits2+2;           % probability 1/4
disp(['N=',int2str(N),',  N1=',int2str(N1),',  bits1=',num2str(bits1),...
      ',  bits2=',num2str(bits2)]);

% This demonstrate some of the features of this coding technique
% it is only effective if the dependencies are to the previous symbol
% and not to the symbol 2 or more positions before.
% Also all possible dependicies where position has information will
% not be resolved.
% It is an effective way of coding completly random binary sequences (where p is
% the same for all symbols and no depenencies).
% Also if the dependency is to the preceeding bit this is effective coding.

% Note that if we force a split in several levels this is not the same as
% splitting for previous symbols '00', '01', '10' and '11'.
% For effective coding, it will always be important to resolve as much as possible
% of the dependencies early in the coding process, i.e. when
% we have most (general) knowledge of the symbols (and any dependencies).

end