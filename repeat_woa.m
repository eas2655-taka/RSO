close all;
clear all;

% enter the number of years to repeat bcs
yrs=5;

N=[320 256];
vars={'SSS_woa2013v2_monthly.bin' 'SST_woa2013v2_monthly.bin'};
wn={'SSS_woa2013v2_repeat5.bin' 'SST_woa2013v2_repeat5.bin'};
Nt=yrs*12;

for n=1:2

   tmp=zeros(N(1),N(2),Nt);
   fn=[vars{n}];
   disp(fn)
   tmp0=loadbin(fn,[N(1) N(2) 12]);
   tmp=repmat(tmp0,[1 1 yrs]);
   fid=fopen(wn{n},'w','ieee-be');
   fwrite(fid,tmp,'float32');
   fclose(fid);
   clear tmp;

end

