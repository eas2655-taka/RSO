close all;
clear all;

% enter the number of years to repeat bcs
yrs=5;

% define grid - Drake Passage -  
%xr=[280 320]; % zonal extent
%yr=[-70 -45]; % meridional extent
%disp('define a new grid');
%xn = linspace(xr(1),xr(2),270);
%yn = linspace(yr(1),yr(2),270);
%you=getenv('USER');
%caseroot=['/data/',you,'/'];
%[x2,y2]=meshgrid(xn,yn);
%x2=x2'; y2=y2';
% ------------------------------
% alternatively just load in x and y
%x2=rdmds('grid_UFZ/XC');
%y2=rdmds('grid_UFZ/YC');
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
   fn=['tr',num2str(n),'_west_repeat',num2str(yrs),'.bin'];
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
   fn=['tr',num2str(n),'_east_repeat',num2str(yrs),'.bin'];
   disp(fn)
   tmp0=loadbin(fn,[N(2) 42 12]);
   tmp=repmat(tmp0,[1 1 yrs]);
   wn=['tr',num2str(n),'_east_repeat',num2str(yrs),'.bin'];
   fid=fopen(wn,'w','ieee-be');
   fwrite(fid,tmp,'float32');
   fclose(fid);
   clear tmp;

end

