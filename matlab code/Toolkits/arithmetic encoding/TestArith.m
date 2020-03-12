% TestArith   Test and example of how to use Arith06 and Arith07

%----------------------------------------------------------------------
% Copyright (c) 2000.  Karl Skretting.  All rights reserved.
% Hogskolen in Stavanger (Stavanger University), Signal Processing Group
% Mail:  karl.skretting@tn.his.no   Homepage:  http://www.ux.his.no/~karlsk/
%
% HISTORY:
% Ver. 1.0  10.04.2001  KS: function made
% Ver. 1.1  28.06.2001  KS: more test signals
%----------------------------------------------------------------------

clear all;
close all;
TestSeq=2;     % which test sequence to use
%                1: the same as in TestHuff
%                2: quantized DCT coefficients of AR(1) signal
%                3: some test sequences
%                4: some binary test sequences
%                5: ECG signal
TestH6=0;      % test if Huff06 gives correct result after decompression
TestA6=0;      % test if Arith06 gives correct result after decompression
TestA7=0;      % test if Arith07 gives correct result after decompression
CompareAll=1;  % compare Huff06, Arith06 and Arith07

%% load testing sequence
if TestSeq==1
    xC=cell(15,1);
    randn('state',0);
    if 1                % do not make many values
        xC{1}=zeros(1000,1);
        xC{1}(23:11:990)=floor(10*randn(length(23:11:990),1));
        for k=2:9
            xC{k}=floor(abs(randn(100+100*k,1)*k));
        end
        randn('state',599);
        xC{10}=floor(filter(1,[1,-0.97],randn(2000,1))+0.5);    % an AR-1 signal
        xC{11}=ones(119,1)*7;
        xC{12}=[];
    end
    xC{13}=[124,131:146,(-100):5:160]';
    xC{14}=4351;
    % this next sequence gave an error with previous version (Huff04)
    xC{15}=[1,39,37,329,294,236,406,114,378,192,159,0,165,9,77,178,225,30,...
        286,3,157,34,185,146,15,218,97,82,281,1103,80,45,96,31,90,10,...
        105,163,19,10,2,73,114,14,42,553,15,412,76,158,379,440,256,71,...
        181,1,36,149,137,55,191,117,124,32,20,0,88,221,8]';
elseif TestSeq==2
    Method=8;         % argument used in Mat2Vec
    K=16;
    L=1280;
    Samples=K*L;
    rho=0.95;
    randn('state',599);
    x=filter(1,[1,-rho],randn(Samples,1));    % an AR-1 signal
    x2=dct(reshape(x,K,L));     % DCT transform
    m2=max(abs(x2(:)));
    ThrF=1;Bins=41;
    Del=1.01*m2/(Bins/2-1+ThrF);
    W=UniQuant(x2,Del,ThrF*Del,Bins);
    xC=Mat2Vec(W, Method, K, L);
elseif TestSeq==3
    xC=cell(15,1);
    randn('state',0);
    xC{1}=zeros(1000,1);
    xC{1}(23:11:990)=floor(10*randn(length(23:11:990),1));
    for k=2:4
        xC{k}=floor(abs(randn(100+100*k,1)*k));
    end
    randn('state',599);
    xC{5}=ones(6,1);
    xC{6}=[0];
    xC{7}=-ones(46,1)*27;
    xC{8}=-3276;
    xC{9}=[-3276,-12*ones(1,43),2:45]';
    xC{10}=floor(filter(1,[1,-0.97],randn(400,1))+0.5);    % an AR-1 signal
    xC{11}=ones(119,1)*7;
    xC{12}=[];
    xC{13}=[124,131:146,(-100):5:160]';
    xC{14}=4351;
    xC{15}=[1,39,37,329,294,236,406,114,378,192,159,0,165,9,77,178,225,30,...
        286,3,157,34,185,146,15,218,97,82,281,1103,80,45,96,31,90,10,...
        105,163,19,10,2,73,114,14,42,553,15,412,76,158,379,440,256,71,...
        181,1,36,149,137,55,191,117,124,32,20,0,88,221,8]';
elseif TestSeq==4
    xC=cell(5,1);
    randn('state',1905);
    rand('state',1905);
    p=0.35;
    x=floor(rand(1,300)+p);
    xC{1}=x';
    xC{2}=[x;x];
    xC{2}=xC{2}(:);
    xC{3}=[x;x;x];
    xC{3}=xC{3}(:);
    xC{4}=sign(filter(1,[1,-0.5],randn(400,1)));    % sign of an AR-1 signal
    xC{4}=floor((xC{4}+1)/2);
    x=zeros(800,1);
    x(7:12:600)=1;
    x(3:11:700)=1;
    x(11:7:750)=1;
    xC{5}=x;
elseif TestSeq==5
    % ECG signal
    [x,fs]=GetSignal(11,2000);
    xC=cell(4,1);
    xC{1}=x;
    xC{2}=x-min(x);
    x(2:length(x))=x(2:length(x))-x(1:(length(x)-1));
    xC{3}=x;             % DPCM
    xC{4}=x-min(x);
else
    xC=cell(2,1);
end
xCno=numel(xC);


%% test huffman 06
if TestH6
    OK=1;
    [y, Res]=Huff06(xC,8,0);      % encoding
    xR=Huff06(y);                 % decoding
    for k=1:xCno
        disp(['Number of bits for sequence ',int2str(k),' is ',int2str(Res(k,3))]);
        if (sum(abs(xR{k}-xC{k})))
            disp(['Sequence no ', int2str(k),' has difference ',...
                int2str(sum(abs(xR{k}-xC{k})))]);
            OK=0;
        end
    end
    disp(['Total number of bits ', int2str(Res(xCno+1,3))]);
    if OK
        disp(['The result for Huff06 is OK.']);
    end
end

%% test arithmetic 06
if TestA6
    OK=1;
    [y, Res]=Arith06(xC);      % encoding
    xR=Arith06(y);             % decoding
    for k=1:xCno
        disp(['Number of bits for sequence ',int2str(k),' is ',int2str(Res(k,3))]);
        if (sum(abs(xR{k}-xC{k})))
            disp(['Sequence no ', int2str(k),' has difference ',...
                int2str(sum(abs(xR{k}-xC{k})))]);
            OK=0;
        end
    end
    disp(['Total number of bits ', int2str(Res(xCno+1,3))]);
    if OK
        disp(['The result for Arith06 is OK.']);
    end
end

%% test arithmetic 07
if TestA7
    OK=1;
    [y, Res]=Arith07(xC);      % encoding
    xR=Arith07(y);             % decoding
    for k=1:xCno
        disp(['Number of bits for sequence ',int2str(k),' is ',int2str(Res(k,3))]);
        if (sum(abs(xR{k}-xC{k})))
            disp(['Sequence no ', int2str(k),' has difference ',...
                int2str(sum(abs(xR{k}-xC{k})))]);
            OK=0;
        end
    end
    disp(['Total number of bits ', int2str(Res(xCno+1,3))]);
    if OK
        disp(['The result for Arith07 is OK.']);
    end
end

%% test all
if CompareAll
    tic;   [yH, ResH] = Huff06(xC,8,0);
    disp(['Huff06 used ',num2str(toc),' seconds.']);
    tic;  [y6, Res6] = Arith06(xC);
    disp(['Arith06 used ',num2str(toc),' seconds.']);
    tic;  [y7, Res7] = Arith07(xC);
    disp(['Arith07 used ',num2str(toc),' seconds.']);
    disp('    Symbols,   bits Huff06, bits Arith06, bits Arith07 ');
    disp([ResH(:,[1,3]),Res6(:,3),Res7(:,3)]);
end

% return;


% % prediction filter
% M=25;
% rxx=xcorr(x,x,M);
% a=toeplitz(rxx((M+1):(M+M)))\rxx((M+2):(M+M+1));
% % alternative
% L=length(x);
% X=[x(2:(L-1)),x(1:(L-2)),x(2:(L-1)).^2,x(2:(L-1)).*x(1:(L-2)),x(1:(L-2)).^2];
% d=x(3:L);
% a=(X'*X)\(X'*d);
% xr=floor(X*a+0.5);
% r=xr-d;
% disp(['SNR=',num2str(10*(-log10(r'*r)+log10(d'*d)))]);
% t=1:100;
% plot(t,xr(t),t,d(t),t,r(t));


