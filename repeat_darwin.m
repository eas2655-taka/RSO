close all;
clear all;

% enter the number of years to repeat bcs
yrs=5;

N=[320 256];
vars={'solfe' 'ndep' 'par' 'wspd'};
Nt=yrs*12;

for n=1:4

   tmp=zeros(N(1),N(2),Nt);
   fn=[vars{n},'_ufz.bin'];
   disp(fn)
   tmp0=loadbin(fn,[N(1) N(2) 12]);
   tmp=repmat(tmp0,[1 1 yrs]);
   wn=[vars{n},'_repeat',num2str(yrs),'.bin'];
   fid=fopen(wn,'w','ieee-be');
   fwrite(fid,tmp,'float32');
   fclose(fid);
   clear tmp;

end

