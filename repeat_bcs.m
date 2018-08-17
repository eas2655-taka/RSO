close all;
clear all;

% enter the number of years to repeat bcs
yrs=5;

N=[320 256];

Nt=yrs*12;

for n=1:41

   % north 
   tmp=zeros(N(1),42,Nt);
   fn=['tr',num2str(n),'_north.bin'];
   disp(fn)
   tmp0=loadbin(fn,[N(1) 42 12]);
   tmp=repmat(tmp0,[1 1 yrs]);
   wn=['tr',num2str(n),'_north_repeat',num2str(yrs),'.bin'];
   fid=fopen(wn,'w','ieee-be');
   fwrite(fid,tmp,'float32');
   fclose(fid);
   clear tmp;

   % south 
   tmp=zeros(N(1),42,Nt);
   fn=['tr',num2str(n),'_south.bin'];
   disp(fn)
   tmp0=loadbin(fn,[N(1) 42 12]);
   tmp=repmat(tmp0,[1 1 yrs]);
   wn=['tr',num2str(n),'_south_repeat',num2str(yrs),'.bin'];
   fid=fopen(wn,'w','ieee-be');
   fwrite(fid,tmp,'float32');
   fclose(fid);
   clear tmp;

   % west 
   tmp=zeros(N(2),42,Nt);
   fn=['tr',num2str(n),'_west.bin'];
   disp(fn)
   tmp0=loadbin(fn,[N(2) 42 12]);
   tmp=repmat(tmp0,[1 1 yrs]);
   wn=['tr',num2str(n),'_west_repeat',num2str(yrs),'.bin'];
   fid=fopen(wn,'w','ieee-be');
   fwrite(fid,tmp,'float32');
   fclose(fid);
   clear tmp;

   % west 
   tmp=zeros(N(2),42,Nt);
   fn=['tr',num2str(n),'_east.bin'];
   disp(fn)
   tmp0=loadbin(fn,[N(2) 42 12]);
   tmp=repmat(tmp0,[1 1 yrs]);
   wn=['tr',num2str(n),'_east_repeat',num2str(yrs),'.bin'];
   fid=fopen(wn,'w','ieee-be');
   fwrite(fid,tmp,'float32');
   fclose(fid);
   clear tmp;

end

