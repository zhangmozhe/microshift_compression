function [r,c] = ind2sub_fast(sz,idx);

nrows = sz(1);
r = rem(idx-1,nrows)+1;
c = (idx-r)/nrows + 1;