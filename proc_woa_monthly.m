close all;
clear all;

% define grid - Drake Passage -  
xr=[280 320]; % zonal extent
yr=[-70 -45]; % meridional extent
disp('define a new grid');
xn = linspace(xr(1),xr(2),270);
yn = linspace(yr(1),yr(2),270);
you=getenv('USER');
caseroot=['/data/',you,'/'];
[x2,y2]=meshgrid(xn,yn);
x2=x2'; y2=y2';
% ------------------------------
% alternatively just load in x and y
x2=rdmds('grid_UFZ/XC');
y2=rdmds('grid_UFZ/YC');
N=size(x2);

src='/data/dataset/ocean/woa2013v2/monthly/sss_woa2013v2.nc';
var='SSS';
vars='s_an';

x=ncread([src],'lon');
y=ncread([src],'lat');
taux=ncread([src],vars);
tmp=squeeze(taux(:,:,1,1:12));

disp('interpolate in space');
x0=x;
x(1:180)=x0(181:360);
x(181:360)=x0(1:180)+360;
tmp1(1:180,:,:)=tmp(181:360,:,:);
tmp1(181:360,:,:)=tmp(1:180,:,:);
for j=1:length(y)
  for k=1:12
   dummy=tmp1(:,j,k);
   xave = nanmean(tmp1(:,j,k),1);
   J=find(isnan(tmp1(:,j,k)));
   dummy(J)=squeeze(xave);
   tmp1(:,j,k)=dummy;
  end
end
[x1,y1]=meshgrid(double(x),double(y));
N=size(x2);
taux2=zeros(N(1),N(2),12);
for n=1:12
   disp(['working on n=',num2str(n)])
   taux2(:,:,n) = griddata(x1',y1',tmp1(:,:,n),x2,y2);
end
% write it out
fn=[var,'_woa2013v2_monthly.bin'];
fid=fopen(fn,'w','ieee-be');
fwrite(fid,taux2,'float32');
fclose(fid);

close all;
clear all;

% define grid - Drake Passage -  
xr=[280 320]; % zonal extent
yr=[-70 -45]; % meridional extent
disp('define a new grid');
xn = linspace(xr(1),xr(2),270);
yn = linspace(yr(1),yr(2),270);
you=getenv('USER');
caseroot=['/data/',you,'/'];
[x2,y2]=meshgrid(xn,yn);
x2=x2'; y2=y2';
% ------------------------------
% alternatively just load in x and y
x2=rdmds('grid_UFZ/XC');
y2=rdmds('grid_UFZ/YC');
N=size(x2);

src='/data/dataset/ocean/woa2013v2/monthly/sst_woa2013v2.nc';
var='SST';
vars='t_an';

x=ncread([src],'lon');
y=ncread([src],'lat');
taux=ncread([src],vars);
tmp=squeeze(taux(:,:,1,1:12));

disp('interpolate in space');
x0=x;
x(1:180)=x0(181:360);
x(181:360)=x0(1:180)+360;
tmp1(1:180,:,:)=tmp(181:360,:,:);
tmp1(181:360,:,:)=tmp(1:180,:,:);
for j=1:length(y)
  for k=1:12
   dummy=tmp1(:,j,k);
   xave = nanmean(tmp1(:,j,k),1);
   J=find(isnan(tmp1(:,j,k)));
   dummy(J)=squeeze(xave);
   tmp1(:,j,k)=dummy;
  end
end
[x1,y1]=meshgrid(double(x),double(y));
N=size(x2);
taux2=zeros(N(1),N(2),12);
for n=1:12
   disp(['working on n=',num2str(n)])
   taux2(:,:,n) = griddata(x1',y1',tmp1(:,:,n),x2,y2);
end
% write it out
fn=[var,'_woa2013v2_monthly.bin'];
fid=fopen(fn,'w','ieee-be');
fwrite(fid,taux2,'float32');
fclose(fid);


