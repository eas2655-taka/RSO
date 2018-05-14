%% create a new case of MITgcm regional southern ocean run
close all;
clear all;

%% set path
addpath matlabfiles

%% bathymetry parmeters from create_topo
disp('set case name');
runcase='Drake.64t.10km.42lev';
toponame='Drake';
xr=[280 320]; % zonal extent
yr=[-70 -45]; % meridional extent
disp('define a new grid');
xn = linspace(xr(1),xr(2),270);
yn = linspace(yr(1),yr(2),270);

% load vertical grid
srcdir='grid42/';
zn=-squeeze(rdmds([srcdir,'RC']));

% set year of initial condition to be extracted
yr = 1980

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%--- do not modify under this line---

dx=diff(xn);
dy=diff(yn);
disp(char(['x0=',num2str(xn(1)-dx(1)/2)]));
disp(char(['y0=',num2str(yn(1)-dy(1)/2)]));
[x2,y2]=meshgrid(xn,yn);

you=getenv('USER');
caseroot=['/data/',you,'/'];

vars={'temp' 'salt'};
srcdir='/data/dataset/ocean/SODA/'
mon={'01' '02' '03' '04' '05' '06' '07' '08' '09' '10' '11' '12'};
W=4;

for i=1
 yr0=yr(i);

 disp('===== initial condition based on january of first year');
 for m=1
  fn=[srcdir,'SODA_2.2.4_',num2str(yr0),mon{m},'.cdf'];
  disp(['working on ',fn]);
  x0 = ncread(fn,'lon');
  y0 = ncread(fn,'lat');
  z0 = ncread(fn,'depth');
  z0(1)=0;
  z0(end)=6000;
  I=find(x0>=xn(1)&x0<=xn(end));
  J=find(y0>=yn(1)&y0<=yn(end));
  Iw=find(x0>=xn(1)-5&x0<=xn(end)+5);
  Jw=find(y0>=yn(1)-5&y0<=yn(end)+5);

  for n=1:length(vars)
   tmp = ncread(fn,vars{n});
   [x1,y1]=meshgrid(x0(Iw),y0(Jw));
   x1=x1';
   y1=y1';
   tmp3d = squeeze(tmp(Iw,Jw,:));
   for k=1:length(z0);
      tmp2d=tmp3d(:,:,k);
      N2=size(tmp2d);
      index=find(isnan(tmp2d));
      for l=1:length(index)
         [in,jn]=ind2sub(size(tmp2d),index(l));
         tmp2d(index(l))=nanmean(nanmean(tmp2d(max(1,in-W):min(in+W,N2(1)),max(1,jn-W):min(jn+W,N2(2)))));
         if isnan(tmp2d(index(l)))
            tmp2d(index(l))=nanmean(nanmean(tmp2d));
         end
      end
      tmp3d(:,:,k)=tmp2d;
   end
   for i=1:N2(1)
      for j=1:N2(2)
         tmp3d1(i,j,:)=interp1(z0,squeeze(tmp3d(i,j,:))',zn,'linear');
      end
   end
   [x2,y2]=meshgrid(xn,yn);
   for k=1:length(zn)
      disp(['working on layer =',num2str(k)]);
      tmp2d=tmp3d1(:,:,k);
      tmp3d2(:,:,k,n) = griddata(x1,y1,tmp2d,x2',y2');
   end
   
  end

  % writing the files
  for n=1:length(vars)
   fid=fopen(char([caseroot,runcase,'/SODA_',vars{n},'_init.bin']),'w','ieee-be'); 
   fwrite(fid,tmp3d2(:,:,:,n),'float32'); 
   fclose(fid);
  end

 end
end

