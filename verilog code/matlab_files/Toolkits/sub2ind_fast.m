function idx = sub2ind_fast(sz,rows,cols)

idx = rows + (cols-1)*sz(1);

