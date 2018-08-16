%% create a new case of MITgcm regional southern ocean run
close all;
clear all;

%% set path
addpath matlabfiles

%% bathymetry parmeters
xorig=rdmds('grid_UFZ/XC');
xn=squeeze(xorig(:,1));
yorig=rdmds('grid_UFZ/YC');
yn=squeeze(yorig(1,:));

%xr=[280 320]; % zonal extent
%yr=[-70 -45]; % meridional extent
%disp('define a new grid');
%xn = linspace(xr(1),xr(2),270);
%yn = linspace(yr(1),yr(2),270);

% load vertical grid
srcdir='grid42/';
zn=-squeeze(rdmds([srcdir,'RC']));

% set years of side bcs to be extracted
yr = 2008:2012;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%--- do not modify under this line---

dx=diff(xn);
dy=diff(yn);
disp(char(['x0=',num2str(xn(1)-dx(1)/2)]));
disp(char(['y0=',num2str(yn(1)-dy(1)/2)]));
[x2,y2]=meshgrid(xn,yn);

disp('===== develop side bcs based on SOSE ');
vars={'UVEL' 'VVEL' 'THETA' 'SALT' 'TRAC02' 'TRAC01' 'TRAC05' 'TRAC04' 'TRAC06' 'TRAC03'};
vars1={'Uvel' 'Vvel' 'Theta' 'Salt' 'Alk' 'DIC' 'PO4' 'NO3' 'Fe' 'O2'};
srcdir='/data2/dataset/ocean/bsose/'

for i=1:length(yr);
 yr0=yr(i);
 offset=(yr0-2008)*12; 

 disp('===== side boundary condition');
 for n=1:length(vars)
  fn=[srcdir,'bsose_i105_2008to2012_monthly_',vars1{n},'.nc'];
  disp(['working on ',fn]);
  if n == 1
  x0 = ncread(fn,'XG');
  y0 = ncread(fn,'YC');
  elseif n==2
  x0 = ncread(fn,'XC');
  y0 = ncread(fn,'YG');
  else
  x0 = ncread(fn,'XC');
  y0 = ncread(fn,'YC');
  end
  z0 = ncread(fn,'Z');
  z0(1)=0;
  z0(end)=-6000;
  z0=-z0;
  I=find(x0>=xn(1)&x0<=xn(end));
  J=find(y0>=yn(1)&y0<=yn(end));
  Iw=find(x0>=xn(1)-5&x0<=xn(end)+5);
  Jw=find(y0>=yn(1)-5&y0<=yn(end)+5);

  for m=1:12
   tmp = ncread(fn,vars{n},[1 1 1 offset+m],[length(x0) length(y0) length(z0) 1]);
   tmp=squeeze(tmp);
   tmp(tmp==0)=NaN;
   if n>=5
     tmp=tmp*1e3;
   end
   % eastern bc
   tmpE = squeeze(tmp(I(end),Jw,:));
   for k=1:length(z0);
    tmpEk = tmpE(:,k);
    tmpEkm= nanmean(tmpEk,1);
    if isnan(tmpEkm)
       tmpEkm = nanmean(tmpE(:,k-1));
    end
    tmpEk(isnan(tmpEk))=tmpEkm;
    tmpE(:,k)=tmpEk;
   end
   [y1,z1]=meshgrid(y0(Jw),z0);
   [y2,z2]=meshgrid(yn,zn);
   tmpE1(:,:,m+12*(i-1),n) = griddata(y1',z1',tmpE,y2',z2');

   % western bc
   tmpW = squeeze(tmp(I(1),Jw,:));
   for k=1:length(z0);
    tmpWk = tmpW(:,k);
    tmpWkm= nanmean(tmpWk,1);
    if isnan(tmpWkm)
       tmpWkm = nanmean(tmpW(:,k-1));
    end
    tmpWk(isnan(tmpWk))=tmpWkm;
    tmpW(:,k)=tmpWk;
   end
   tmpW1(:,:,m+12*(i-1),n) = griddata(y1',z1',tmpW,y2',z2');

   % northern bc
   tmpN = squeeze(tmp(Iw,J(end),:));
   for k=1:length(z0);
    tmpNk = tmpN(:,k);
    tmpNkm= nanmean(tmpNk,1);
    if isnan(tmpNkm)
       tmpNkm = nanmean(tmpN(:,k-1));
    end
    tmpNk(isnan(tmpNk))=tmpNkm;
    tmpN(:,k)=tmpNk;
   end
   [x1,z1]=meshgrid(x0(Iw),z0);
   [x2,z2]=meshgrid(xn,zn);
   tmpN1(:,:,m+12*(i-1),n) = griddata(x1',z1',tmpN,x2',z2');

   % southern bc
   tmpS = squeeze(tmp(Iw,J(1),:));
   for k=1:length(z0);
    tmpSk = tmpS(:,k);
    tmpSkm= nanmean(tmpSk,1);
    if isnan(tmpSkm)
       tmpSkm = nanmean(tmpS(:,k-1));
    end
    tmpSk(isnan(tmpSk))=tmpSkm;
    tmpS(:,k)=tmpSk;
   end
   tmpS1(:,:,m+12*(i-1),n) = griddata(x1',z1',tmpS,x2',z2');

  end% end loop for months
 end% end loop for vars
end% end loop for year

 % writing the files
for n=1:length(vars)
   fid=fopen(char(['BSOSE_',vars1{n},'_east_',num2str(yr(1)),'_',num2str(yr(end)),'.bin']),'w','ieee-be');
   fwrite(fid,tmpE1(:,:,:,n),'float32');
   fclose(fid);
   fid=fopen(char(['BSOSE_',vars1{n},'_west_',num2str(yr(1)),'_',num2str(yr(end)),'.bin']),'w','ieee-be');
   fwrite(fid,tmpW1(:,:,:,n),'float32');
   fclose(fid);
   fid=fopen(char(['BSOSE_',vars1{n},'_north_',num2str(yr(1)),'_',num2str(yr(end)),'.bin']),'w','ieee-be');
   fwrite(fid,tmpN1(:,:,:,n),'float32');
   fclose(fid);
   fid=fopen(char(['BSOSE_',vars1{n},'_south_',num2str(yr(1)),'_',num2str(yr(end)),'.bin']),'w','ieee-be');
   fwrite(fid,tmpS1(:,:,:,n),'float32');
   fclose(fid);
end% end loop for vars


