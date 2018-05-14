function x=loadbin(fn,dim);

fid=fopen(char(fn),'r','ieee-be');
dat=fread(fid,prod(dim),'float32');
x=reshape(dat,dim);
fclose(fid);
return;