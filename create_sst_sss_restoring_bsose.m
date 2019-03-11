%% create a new case of MITgcm regional southern ocean run
close all;
clear all;

%% set path
addpath matlabfiles

% bathymetry parmeters
%xorig=rdmds('grid_UFZ/XC');
%xn=squeeze(xorig(:,1));
%yorig=rdmds('grid_UFZ/YC');
%yn=squeeze(yorig(1,:));

disp('Drake Grid');
xr=[280 320]; % zonal extent
yr=[-70 -45]; % meridional extent
xn = linspace(xr(1),xr(2),270);
yn = linspace(yr(1),yr(2),270);

% set years of side bcs to be extracted
yr = 2008:2012;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%--- do not modify under this line---
dx=diff(xn);
dy=diff(yn);
disp(char(['x0=',num2str(xn(1)-dx(1)/2)]));
disp(char(['y0=',num2str(yn(1)-dy(1)/2)]));
[x2,y2]=meshgrid(xn,yn);
N=size(x2');

disp('===== develop SST and SSS bcs based on B-SOSE ');
vars={'THETA' 'SALT'};
vars1={'Theta' 'Salt'};
srcdir='/data2/dataset/ocean/bsose/'

SST=zeros(N(1),N(2),12);
SSS=zeros(N(1),N(2),12);

for i=1:length(yr);
 yr0=yr(i);
 offset=(yr0-2008)*12; 

 disp('===== side boundary condition');
 for n=1:length(vars)
  fn=[srcdir,'bsose_i105_2008to2012_monthly_',vars1{n},'.nc'];
  disp(['working on ',fn]);
  x0 = ncread(fn,'XC');
  y0 = ncread(fn,'YC');
  [x1,y1]=meshgrid(x0,y0);

  parfor m=1:12
   tmp = ncread(fn,vars{n},[1 1 1 offset+m],[length(x0) length(y0) 1 1]);
   tmp=squeeze(tmp);
   disp('removing NaNs from the original data');
   % removing NaNs with nearest members
   tmp(tmp==0)=NaN;
   I=find(isnan(tmp));
   while(~isempty(I))
      tmp(I)=tmp(I+1);
      I=find(isnan(tmp));
   end
   % interpolation
   disp('2d interpolation');
   if n == 1
      tmpsfc=griddata(x1',y1',tmp,x2',y2');
      SST(:,:,m)=SST(:,:,m)+tmpsfc;
   elseif n==2
      tmpsfc=griddata(x1',y1',tmp,x2',y2');
      SSS(:,:,m)=SSS(:,:,m)+tmpsfc;
   end
  end% end loop for months
 end% end loop for vars
end% end loop for year

SST=SST/length(yr);
SSS=SSS/length(yr);

SSTw=repmat(SST,[1 1 5]);
SSSw=repmat(SSS,[1 1 5]);

% writing the files
fid=fopen(char(['BSOSE_SST_2008_2012.bin']),'w','ieee-be');
fwrite(fid,SSTw,'float32');
fclose(fid);

fid=fopen(char(['BSOSE_SSS_2008_2012.bin']),'w','ieee-be');
fwrite(fid,SSSw,'float32');
fclose(fid);

