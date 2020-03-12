function HLlen = HuffTabLen(HL)
% HuffTabLen  Find how many bits we need to store the Huffman Table information
%
% HLlen = HuffTabLen(HL); 
%----------------------------------------------------------------------
% arguments:
%  HL       The codeword lengths, as returned from HuffLen function
%           This should be a vector of integers 
%           where  0 <= HL(i) <= 32, 0 is for unused symbols
%           We then have max codeword length is 32
%  HLlen    Number of bits needed to store the table
%----------------------------------------------------------------------

% Function assume that the table information is stored in the following format
%        previous code word length is set to the initial value 2
%        Then we have for each symbol a code word to tell its length 
%         '0'             - same length as previous symbol
%         '10'            - increase length by 1, and 17->1
%         '1100'          - reduce length by 1, and 0->16
%         '11010'         - increase length by 2, and 17->1, 18->2
%         '11011'         - One zero, unused symbol (twice for two zeros)
%         '111xxxx'       - set code length to CL=Prev+x (where 3 <= x <= 14)
%                           and if CL>16; CL=CL-16
%        we have 4 unused 7 bit code words, which we give the meaning
%         '1110000'+4bits - 3-18 zeros
%         '1110001'+8bits - 19-274 zeros, zeros do not change previous value
%         '1110010'+4bits - for CL=17,18,...,32, do not change previous value
%         '1111111'       - End Of Table

%----------------------------------------------------------------------
% Copyright (c) 1999.  Karl Skretting.  All rights reserved.
% Hogskolen in Stavanger (Stavanger University), Signal Processing Group
% Mail:  karl.skretting@tn.his.no   Homepage:  http://www.ux.his.no/~karlsk/
% 
% HISTORY:
% Ver. 1.0  18.08.99  KS, function made as an own m-file (another version
%                     is included in the Huff04 m-file)
%           25.08.99  KS: now we use this format also in Huff04
%                     if you change here, remember to also update Huff04!!
% Ver. 1.2  26.08.99  KS: Reduced number of bits used for zeros (increased for +2)
% Ver. 1.3  20.06.00  KS: Removed the KeepStatistics lines
% Ver. 1.4  18.01.01  KS: Removed error message if HL is out of (normal) range.
% Ver. 1.5  21.08.01  KS: Allow HL to be in range  0 <= HL(i) <= 32
%----------------------------------------------------------------------

Mfile='HuffTabLen';
% KeepStatistics=0;  % we may want to keep statistics to see wether the chosen 
                   % code words are well suited
if (nargin ~= 1); 
   error([Mfile,': function must have one input arguments, see help.']); 
end
if (nargout ~= 1); 
   error([Mfile,': function must have one output arguments, see help.']); 
end
HL=HL(:);

if (max(HL) > 32) 
   disp([Mfile,': To large value in HL, max(HL)=',int2str(max(HL))]); 
end
if (min(HL) < 0)
   disp([Mfile,': To small value in HL, min(HL)=',int2str(min(HL))]); 
end

Prev=2;
HLlen=0;
ZeroCount=0;
% if KeepStatistics; load HuffTabLenStat; end;   % IncStat=zeros(16,1);RunStat=zeros(512,1);

L=length(HL);
for l=1:L
   if HL(l)==0
      ZeroCount=ZeroCount+1;
   else
      % if (ZeroCount & KeepStatistics) 
      %    j=min([512,ZeroCount]); RunStat(j)=RunStat(j)+1; 
      % end
      while (ZeroCount > 0)
         if ZeroCount<3; HLlen=HLlen+5*ZeroCount; ZeroCount=0; 
         elseif ZeroCount<19; HLlen=HLlen+11; ZeroCount=0; 
         elseif ZeroCount<275; HLlen=HLlen+15; ZeroCount=0; 
         else HLlen=HLlen+15; ZeroCount=ZeroCount-274; end;
      end
      if HL(l)>16
         HLlen=HLlen+11;
      else
         Inc=HL(l)-Prev;
         if Inc<0; Inc=Inc+16; end;
         % if KeepStatistics; j=Inc+1; IncStat(j)=IncStat(j)+1; end;
         if (Inc==0); HLlen=HLlen+1;
         elseif (Inc==1); HLlen=HLlen+2;
         elseif (Inc==2); HLlen=HLlen+5;
         elseif (Inc==15); HLlen=HLlen+4;
         else HLlen=HLlen+7;
         end
         Prev=HL(l);
      end
   end
end
HLlen=HLlen+7;       % the EOT codeword

% if KeepStatistics; save HuffTabLenStat IncStat RunStat; end; 

return;  % end of HuffTabLen
